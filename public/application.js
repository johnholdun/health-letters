(function () {
  var HTMLS;

  var ajax = function (options) {
    var request = new XMLHttpRequest();
    request.open((options.type || "GET").toUpperCase(), options.url, true);
    request.onload = function () { options.success(request) };
    request.onerror = function () { options.error(request) };
    request.setRequestHeader("X-Requested-With", "XMLHttpRequest");

    if (options.data) {
      request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
      request.send(options.data);
    } else {
      request.send();
    }
  };

  var navigate = function (request) {
    HTMLS.push({
      title: request.getResponseHeader("X-Page-Title"),
      body: request.responseText
    });

    loadPage(HTMLS[HTMLS.length - 1]);

    history.pushState({ index: HTMLS.length - 1 }, null, request.responseURL);
  };

  var geolocate = function () {
    var form = document.querySelector("[data-js='geolocate-form']");

    navigator.geolocation.getCurrentPosition(function (geo) {
      var body = "latitude=" + geo.coords.latitude;
      body += "&longitude=" + geo.coords.longitude;

      ajax({
        type: form.getAttribute("method"),
        url: form.getAttribute("action"),
        data: body,
        success: navigate
      });
    });
  };

  var loadPage = function(page) {
    document.title = page.title;
    document.body.outerHTML = page.body;
    window.scrollTo(0, 0);
  };

  addEventListener("load", function () {
    HTMLS = [{
      body: document.body.outerHTML,
      title: document.title
    }];

    history.replaceState({ index: 0 }, null, location.href);

    addEventListener("submit", function (e) {
      if (e.target.getAttribute("data-js") !== "geolocate-form") {
        return true;
      }

      e.preventDefault();
      geolocate();
    });

    addEventListener("click", function (e) {
      var href;

      if (e.target.nodeName !== "A") {
        return true;
      }

      href = e.target.getAttribute("href").toString();

      if (href.match(/^#|(?:(?:https?:)?\/\/)/)) {
        return true;
      }

      e.preventDefault();

      ajax({ url: href, success: navigate });
    });
  });

  addEventListener("popstate", function (e) {
    loadPage(HTMLS[e.state.index]);
  });
})();
