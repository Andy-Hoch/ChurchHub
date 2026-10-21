// The launcher that churches embed on their websites: a floating button with
// a panel of links, in which forms open one step after another. Plain ES5 in one file,
// without modules or a build step, because it runs on all kinds of church
// websites in all kinds of browsers.
//
// This file only defines window.KirchenHub. The data of a hub comes from
// /embed/<token>.js (see EmbedController), which calls KirchenHub.mount.
(function () {
  "use strict";

  if (window.KirchenHub) return;

  var ICONS = {
    grid: '<path d="M4 4h6v6H4zM14 4h6v6h-6zM4 14h6v6H4zM14 14h6v6h-6z"/>',
    menu: '<path d="M4 6h16M4 12h16M4 18h16"/>',
    heart: '<path d="M19 14c1.5-1.5 3-3.2 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.8 0-3 .5-4.5 2-1.5-1.5-2.7-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4 3 5.5l7 7z"/>',
    cross: '<path d="M12 2v20M6 8h12"/>',
    link: '<path d="M10 13a5 5 0 0 0 7.5.5l3-3a5 5 0 0 0-7-7l-1.7 1.7"/><path d="M14 11a5 5 0 0 0-7.5-.5l-3 3a5 5 0 0 0 7 7l1.7-1.7"/>',
    close: '<path d="M18 6 6 18M6 6l12 12"/>',
    arrowLeft: '<path d="M19 12H5M12 19l-7-7 7-7"/>',
    arrowRight: '<path d="M5 12h14M12 5l7 7-7 7"/>',
    check: '<circle cx="12" cy="12" r="10"/><path d="m8 12 3 3 5-6"/>'
  };

  var MESSAGES = {
    required: "Bitte beantworte diese Frage.",
    email: "Bitte gib eine gültige E-Mail-Adresse ein.",
    phone: "Bitte gib eine gültige Telefonnummer ein.",
    number: "Bitte gib eine Zahl ein.",
    date: "Bitte gib ein gültiges Datum ein.",
    consent: "Bitte stimme der Datenverarbeitung zu.",
    network: "Das Absenden hat nicht geklappt. Bitte prüfe deine Verbindung und versuche es erneut.",
    discard: "Deine Eingaben gehen verloren. Formular wirklich schließen?"
  };

  var FORMATS = {
    email: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
    phone: /^\+?[\d\s()\/.-]{5,30}$/,
    number: /^-?\d+([.,]\d+)?$/,
    date: /^\d{4}-\d{2}-\d{2}$/
  };

  var INPUT_TYPES = { email: "email", phone: "tel", date: "date" };

  var STYLES = [
    ":host { all: initial; }",
    ".launcher { --radius: calc(var(--ph-radius) * 1px); color-scheme: var(--ph-scheme); font: 400 15px/1.4 var(--ph-font); position: fixed; inset-block-end: 20px; z-index: 2147483000; display: flex; flex-direction: column; align-items: flex-end; gap: 12px; }",
    ".launcher--right { inset-inline-end: 20px; }",
    ".launcher--left { inset-inline-start: 20px; align-items: flex-start; }",
    ":host([data-inline]) .launcher { position: absolute; inset-block-end: 16px; }",
    ":host([data-inline]) .launcher--right { inset-inline-end: 16px; }",
    ":host([data-inline]) .launcher--left { inset-inline-start: 16px; }",
    ".button { all: unset; box-sizing: border-box; cursor: pointer; display: inline-flex; align-items: center; justify-content: center; gap: 8px; padding: 12px 18px; border-radius: 999px; background: var(--ph-primary); color: var(--ph-text); font-weight: 600; box-shadow: 0 10px 25px -5px oklch(0% 0 0 / .25), 0 4px 6px -4px oklch(0% 0 0 / .2); transition: transform .15s ease; }",
    ".button--icon-only { padding: 12px; gap: 0; }",
    ".button:hover { transform: translateY(-1px); }",
    ".button:active { transform: scale(.97); }",
    ".button:focus-visible, .link:focus-visible, .close:focus-visible { outline: 2px solid var(--ph-primary); outline-offset: 2px; }",
    ".icon { width: 20px; height: 20px; fill: none; stroke: currentColor; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; flex-shrink: 0; }",
    ".panel { box-sizing: border-box; width: min(360px, calc(100vw - 40px)); max-height: min(560px, calc(100vh - 110px)); overflow: auto; background: light-dark(oklch(96.74% 0.0013 286.38), oklch(14.08% 0.0044 285.82)); color: light-dark(oklch(14.08% 0.0044 285.82), oklch(98.51% 0 0)); border: 1px solid light-dark(oklch(91.97% 0.004 286.32), oklch(37.03% 0.0119 285.81)); border-radius: var(--radius); box-shadow: 0 20px 25px -5px oklch(0% 0 0 / .15), 0 8px 10px -6px oklch(0% 0 0 / .1); transform-origin: bottom right; animation: ph-in .18s ease-out; }",
    ".launcher--left .panel { transform-origin: bottom left; }",
    ".panel[hidden] { display: none; }",
    ".header { display: flex; align-items: center; justify-content: space-between; gap: 8px; padding: 14px 16px; background: var(--ph-primary); color: var(--ph-text); }",
    ".title { margin: 0; font-size: 16px; font-weight: 600; }",
    ".close { all: unset; cursor: pointer; display: inline-flex; padding: 4px; border-radius: 6px; }",
    ".list { padding: 16px; display: grid; justify-items: center; gap: 14px; }",
    "button.link { all: unset; }",
    "a.link, button.link { box-sizing: border-box; min-width: min(100%, 12rem); max-width: 100%; cursor: pointer; display: flex; align-items: center; justify-content: center; min-height: 64px; padding: 16px 28px; background: light-dark(oklch(100% 0 0), oklch(21.03% 0.0059 285.89)); border: 1px solid light-dark(oklch(91.97% 0.004 286.32), oklch(37.03% 0.0119 285.81)); border-radius: var(--radius); color: inherit; text-decoration: none; text-align: center; box-shadow: 0 1px 3px oklch(0% 0 0 / .06); transition: transform .15s ease, background-color .15s ease; }",
    ".link:hover { background: light-dark(oklch(96.74% 0.0013 286.38), oklch(27.39% 0.0055 286.03)); }",
    ".link:active { transform: scale(.98); }",
    ".link-text { min-width: 0; max-width: 100%; }",
    ".link-title { display: block; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }",
    "@media (prefers-reduced-motion: reduce) { .link { transition: none; } }",
    ".empty { padding: 16px; margin: 0; color: light-dark(oklch(55.17% 0.0138 285.94), oklch(71.18% 0.0129 286.07)); }",
    "@keyframes ph-in { from { opacity: 0; transform: translateY(8px) scale(.98); } }",
    "@media (max-width: 640px) { :host(:not([data-inline])) .panel { position: fixed; inset: 0; width: 100%; height: 100%; height: 100dvh; max-height: none; border: 0; border-radius: 0; padding-bottom: env(safe-area-inset-bottom); overscroll-behavior: contain; } :host(:not([data-inline])) .header { position: sticky; top: 0; padding-top: max(14px, env(safe-area-inset-top)); } :host(:not([data-inline])) .panel:not([hidden]) + .button { display: none; } :host(:not([data-inline])) .close { padding: 8px; } }",

    ".panel--form { display: flex; flex-direction: column; height: min(560px, calc(100vh - 110px)); overflow: hidden; }",
    ".backdrop { --radius: calc(var(--ph-radius) * 1px); color-scheme: var(--ph-scheme); font: 400 15px/1.4 var(--ph-font); position: fixed; inset: 0; z-index: 2147483001; display: flex; align-items: center; justify-content: center; padding: 20px; background: oklch(0% 0 0 / .45); animation: ph-fade .2s ease-out; }",
    ":host([data-inline]) .backdrop { position: absolute; }",
    ".backdrop .panel { height: min(560px, calc(100vh - 40px)); max-height: none; transform-origin: center; }",
    "@media (max-width: 640px) { .backdrop { padding: 0; } .backdrop .panel { width: 100%; height: 100%; height: 100dvh; border: 0; border-radius: 0; padding-bottom: env(safe-area-inset-bottom); } .backdrop .header { padding-top: max(14px, env(safe-area-inset-top)); } }",

    ".form { --border: light-dark(oklch(91.97% 0.004 286.32), oklch(37.03% 0.0119 285.81)); --muted: light-dark(oklch(55.17% 0.0138 285.94), oklch(71.18% 0.0129 286.07)); --negative: light-dark(oklch(57.71% 0.2152 27.33), oklch(70.4% 0.191 22.22)); flex: 1; min-height: 0; display: flex; flex-direction: column; background: light-dark(oklch(100% 0 0), oklch(21.03% 0.0059 285.89)); }",
    ".form *, .form *::before, .form *::after { box-sizing: border-box; }",
    ".form .title { flex: 1; min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }",
    ".progress { height: 4px; flex-shrink: 0; background: var(--border); }",
    ".progress-bar { height: 100%; background: var(--ph-primary); transition: width .25s ease; }",
    // One step per slide, side by side: swiping snaps from step to step.
    ".slides { flex: 1; min-height: 0; display: grid; grid-auto-flow: column; grid-auto-columns: 100%; grid-template-rows: 100%; overflow-x: auto; overflow-y: hidden; scroll-snap-type: x mandatory; overscroll-behavior-x: contain; scrollbar-width: none; }",
    ".slides::-webkit-scrollbar { display: none; }",
    ".slide { min-width: 0; scroll-snap-align: start; scroll-snap-stop: always; overflow-y: auto; overscroll-behavior-y: contain; padding: 20px 16px; }",
    ".step-count { margin: 0 0 6px; font-size: 13px; font-weight: 600; color: var(--muted); }",
    ".question { margin: 0 0 8px; font-size: 20px; font-weight: 650; line-height: 1.25; overflow-wrap: anywhere; }",
    ".optional { font-size: 14px; font-weight: 400; color: var(--muted); }",
    ".help, .intro { margin: 0 0 8px; color: var(--muted); white-space: pre-line; overflow-wrap: anywhere; }",
    ".intro { font-size: 16px; color: inherit; }",
    ".input { display: block; width: 100%; margin-top: 14px; font: inherit; font-size: 16px; padding: 10px 12px; color: inherit; background: transparent; border: 1px solid var(--border); border-radius: calc(var(--radius) * .66); }",
    ".input:focus, .option:has(:focus-visible) { outline: 2px solid var(--ph-primary); outline-offset: 1px; }",
    ".input[aria-invalid=true] { border-color: var(--negative); }",
    "textarea.input { min-height: 120px; resize: vertical; }",
    ".options { display: grid; gap: 8px; margin-top: 14px; }",
    ".option { display: flex; align-items: center; gap: 12px; padding: 12px 14px; border: 1px solid var(--border); border-radius: calc(var(--radius) * .66); cursor: pointer; overflow-wrap: anywhere; }",
    ".option:has(:checked) { border-color: var(--ph-primary); box-shadow: inset 0 0 0 1px var(--ph-primary); }",
    ".option input { flex-shrink: 0; width: 18px; height: 18px; margin: 0; accent-color: var(--ph-primary); }",
    ".error { margin: 12px 0 0; color: var(--negative); font-size: 14px; font-weight: 500; }",
    ".error:empty { display: none; }",
    ".review { margin: 12px 0 0; padding: 0; }",
    ".review-item { display: flex; align-items: flex-start; gap: 12px; padding: 10px 0; border-bottom: 1px solid var(--border); }",
    ".review-text { flex: 1; min-width: 0; }",
    ".review-label { display: block; font-size: 13px; color: var(--muted); }",
    ".review-value { display: block; margin: 2px 0 0; white-space: pre-line; overflow-wrap: anywhere; }",
    ".review-value--empty { color: var(--muted); font-style: italic; }",
    ".review .error { margin: 4px 0 0; }",
    ".edit { all: unset; cursor: pointer; font-size: 14px; font-weight: 600; text-decoration: underline; padding: 2px 4px; border-radius: 4px; }",
    ".consent { display: flex; align-items: flex-start; gap: 10px; margin-top: 16px; font-size: 14px; cursor: pointer; }",
    ".consent input { flex-shrink: 0; width: 18px; height: 18px; margin: 1px 0 0; accent-color: var(--ph-primary); }",
    ".consent a, .privacy a { color: inherit; }",
    ".privacy { margin: 16px 0 0; font-size: 14px; color: var(--muted); }",
    ".done { flex: 1; overflow-y: auto; padding: 32px 16px; text-align: center; }",
    ".done .icon { width: 56px; height: 56px; color: var(--ph-primary); stroke-width: 1.5; margin-bottom: 12px; }",
    ".form-footer { display: flex; align-items: center; gap: 12px; padding: 12px 16px; border-top: 1px solid var(--border); }",
    ".btn { all: unset; box-sizing: border-box; cursor: pointer; display: inline-flex; align-items: center; justify-content: center; gap: 8px; min-height: 44px; padding: 10px 20px; border-radius: max(8px, calc(var(--radius) * .66)); font-weight: 600; text-align: center; }",
    ".btn .icon { width: 18px; height: 18px; }",
    ".btn[hidden] { display: none; }",
    ".btn-icon { padding: 10px 12px; }",
    ".btn-primary { margin-inline-start: auto; background: var(--ph-primary); color: var(--ph-text); }",
    ".btn-secondary { border: 1px solid var(--border); }",
    ".btn[disabled] { opacity: .6; cursor: default; }",
    ".btn:focus-visible, .edit:focus-visible { outline: 2px solid var(--ph-primary); outline-offset: 2px; }",
    ".hp { position: absolute; left: -10000px; width: 1px; height: 1px; overflow: hidden; }",
    "@keyframes ph-fade { from { opacity: 0; } }",
    "@media (prefers-reduced-motion: reduce) { .panel, .backdrop { animation: none; } .button, .progress-bar { transition: none; } }"
  ].join("\n");

  function svg(name, className) {
    return '<svg class="icon' + (className ? " " + className : "") + '" viewBox="0 0 24 24" aria-hidden="true">' + (ICONS[name] || ICONS.grid) + "</svg>";
  }

  function safeUrl(url) {
    return /^https?:\/\//i.test(url || "") ? url : null;
  }

  function el(tag, className, text) {
    var node = document.createElement(tag);
    if (className) node.className = className;
    if (text) node.textContent = text;
    return node;
  }

  function button(className, text, onClick) {
    var node = el("button", className, text);
    node.type = "button";
    node.addEventListener("click", onClick);
    return node;
  }

  function isBlank(value) {
    return Array.isArray(value) ? value.length === 0 : !String(value == null ? "" : value).trim();
  }

  // Mirrors FormQuestion#parse_answer on the server.
  function validate(question, value) {
    if (isBlank(value)) return question.required ? MESSAGES.required : null;
    if (Array.isArray(value)) return null;

    value = String(value).trim();
    if (question.maxLength && value.length > question.maxLength) return "Bitte höchstens " + question.maxLength + " Zeichen.";
    if (FORMATS[question.kind] && !FORMATS[question.kind].test(value)) return MESSAGES[question.kind];
    return null;
  }

  function formatAnswer(question, value) {
    if (isBlank(value)) return null;
    if (Array.isArray(value)) return value.join(", ");
    if (question.kind === "date" && FORMATS.date.test(value)) return value.split("-").reverse().join(".");
    return String(value).trim();
  }


  // @font-face rules are ignored inside a shadow root, so they go into the
  // page itself (the public hub page already ships them).
  function loadFonts(fontFaces, nonce) {
    if (document.querySelector("style[data-kirchen-hub-fonts]")) return;
    var style = document.createElement("style");
    style.setAttribute("data-kirchen-hub-fonts", "");
    if (nonce) style.nonce = nonce;
    style.textContent = fontFaces;
    document.head.appendChild(style);
  }

  // config: { hub, allowedHosts, fonts, fontFaces }, see EmbedHelper#embed_config.
  // script: the <script> element that loaded the hub. Its data attributes are
  // options: data-launcher="false" skips the floating button and only opens
  // forms from page elements with data-kirchen-hub-form="<form id>" (the
  // public hub page), data-container mounts into that element instead of the
  // body (the admin preview), data-open="true" starts with the panel open.
  // Submissions go to /embed/<token>/forms/<id>/submissions next to the
  // script; inline copies (the admin preview) have no src and only simulate
  // sending. A nonce on the script is passed on to the launcher's styles, for
  // pages with a content security policy.
  function mount(config, script) {
    var allowedHosts = config.allowedHosts;
    var pageHost = location.hostname.toLowerCase();

    if (allowedHosts && !allowedHosts.some(function (host) { return pageHost === host || pageHost.slice(-host.length - 1) === "." + host; })) {
      if (window.console) console.warn("Kirchen-Hub: Der Launcher ist für diese Webseite nicht freigegeben.");
      return;
    }

    var data = config.hub;
    var options = (script && script.dataset) || {};
    var endpoint = script && script.src ? script.src.replace(/\.js(\?.*)?$/, "") : null;
    var nonce = (script && script.nonce) || "";

    if (document.body) {
      start();
    } else {
      document.addEventListener("DOMContentLoaded", start);
    }

    function start() {
      loadFonts(config.fontFaces, nonce);
      var container = options.container ? document.querySelector(options.container) : document.body;
      if (!container) return;

      var previous = container.querySelector(":scope > [data-kirchen-hub]");
      if (previous) previous.remove();

      var host = document.createElement("div");
      host.setAttribute("data-kirchen-hub", "");
      if (options.container) host.setAttribute("data-inline", "");
      var root = host.attachShadow({ mode: "open" });
      var theme = Object.assign({}, data.theme);
      var open = options.open === "true";
      var headless = options.launcher === "false";
      var activeForm = null;
      var panel = null;
      var privacy = data.privacy || {};
      var reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");

      var style = el("style");
      style.textContent = STYLES;
      if (nonce) style.nonce = nonce;
      var launcher = el("div", "launcher");
      var formLayer = el("div");
      root.append(style, launcher, formLayer);
      container.appendChild(host);

      function render() {
        host.style.setProperty("--ph-primary", theme.primaryColor);
        host.style.setProperty("--ph-text", theme.textColor);
        host.style.setProperty("--ph-radius", String(theme.cornerRadius));
        host.style.setProperty("--ph-scheme", theme.colorScheme === "auto" ? "light dark" : theme.colorScheme);
        host.style.setProperty("--ph-font", config.fonts[theme.fontFamily] || config.fonts.sans);
        launcher.className = "launcher launcher--" + (theme.position === "left" ? "left" : "right");
        launcher.replaceChildren();
        if (headless) return;

        var panelId = "kirchen-hub-panel";
        panel = el("div", "panel");
        panel.id = panelId;
        panel.setAttribute("role", "dialog");
        panel.hidden = !open;

        var toggleButton = el("button", "button" + (theme.buttonLabel ? "" : " button--icon-only"));
        toggleButton.type = "button";
        toggleButton.setAttribute("aria-expanded", String(open));
        toggleButton.setAttribute("aria-controls", panelId);
        toggleButton.setAttribute("aria-label", open ? "Schließen" : (theme.buttonLabel || "Menü öffnen"));
        toggleButton.innerHTML = svg(open ? "close" : theme.buttonIcon);
        if (theme.buttonLabel) toggleButton.appendChild(el("span", null, theme.buttonLabel));

        launcher.append(panel, toggleButton);
        fillPanel();

        toggleButton.addEventListener("click", function () { toggle(!open, true); });
      }

      // The panel shows either the links or the open form.
      function fillPanel() {
        if (activeForm) {
          panel.className = "panel panel--form";
          panel.setAttribute("aria-label", activeForm.form.title);
          panel.replaceChildren(activeForm.node);
          restoreScroll();
          return;
        }

        panel.className = "panel";
        panel.setAttribute("aria-label", data.title);

        var header = el("div", "header");
        var close = button("close", null, function () { toggle(false, true); });
        close.setAttribute("aria-label", "Schließen");
        close.innerHTML = svg("close");
        header.append(el("h2", "title", data.title), close);
        panel.replaceChildren(header);

        if (data.links.length === 0) {
          panel.appendChild(el("p", "empty", "Noch keine Links vorhanden."));
          return;
        }

        var list = el("div", "list");
        data.links.forEach(function (item) {
          var node;
          if (item.type === "form" && item.form) {
            node = button("link", null, function () { openForm(item.form, node); });
            node.setAttribute("aria-haspopup", "dialog");
            node.setAttribute("data-form-id", item.form.id);
          } else {
            var href = safeUrl(item.url);
            if (!href) return;
            node = el("a", "link");
            node.href = href;
            node.target = "_blank";
            node.rel = "noopener";
          }
          node.title = item.title;
          var text = el("span", "link-text");
          text.appendChild(el("span", "link-title", item.title));
          node.appendChild(text);
          list.appendChild(node);
        });
        panel.appendChild(list);
      }

      // Forms open inside the launcher panel (on the public hub page, where
      // there is no launcher, in a card of the same size). Every step (intro,
      // one per question, review, privacy) is a slide of its own; they sit side
      // by side and are reached by swiping or with the buttons below.

      function openForm(form, trigger) {
        var steps = [];
        if (form.intro) steps.push({ type: "intro" });
        form.questions.forEach(function (question, index) {
          steps.push({ type: "question", question: question, number: index + 1 });
        });
        steps.push({ type: "review" });
        var reviewIndex = steps.length - 1;
        // Consent text and/or privacy link get a step of their own right before sending.
        if (privacy.consentText || safeUrl(privacy.privacyUrl)) steps.push({ type: "privacy" });

        activeForm = {
          reviewIndex: reviewIndex,
          form: form, steps: steps, index: 0, answers: {}, errors: {}, consent: false, honeypot: "",
          returnToReview: false, submitting: false, done: false, error: "", startedAt: Date.now(), trigger: trigger,
          scrollTarget: null, scrollUntil: 0
        };
        buildForm();

        if (headless) {
          var dialog = el("div", "panel panel--form");
          dialog.setAttribute("role", "dialog");
          dialog.setAttribute("aria-modal", "true");
          dialog.setAttribute("aria-label", form.title);
          dialog.appendChild(activeForm.node);
          var backdrop = el("div", "backdrop");
          backdrop.appendChild(dialog);
          backdrop.addEventListener("click", function (event) {
            if (event.target === backdrop) closeForm(true);
          });
          formLayer.replaceChildren(backdrop);
        } else {
          fillPanel();
        }
        lockScroll();
        focusStep();
      }

      function closeForm(askFirst) {
        var state = activeForm;
        if (!state) return;
        if (askFirst && !state.done && isDirty(state) && !window.confirm(MESSAGES.discard)) return;

        activeForm = null;
        if (headless) {
          formLayer.replaceChildren();
        } else if (panel) {
          fillPanel();
        }
        lockScroll();
        var target = state.trigger && state.trigger.isConnected
          ? state.trigger
          : root.querySelector("[data-form-id='" + state.form.id + "']") || root.querySelector(".link, .button");
        if (target) target.focus();
      }

      function isDirty(state) {
        return Object.keys(state.answers).some(function (id) { return !isBlank(state.answers[id]); });
      }

      function buildForm() {
        var state = activeForm;
        var form = state.form;
        var ui = state.ui = {};

        var header = el("div", "header");
        var close = button("close", null, function () { closeForm(true); });
        close.setAttribute("aria-label", "Formular schließen");
        close.innerHTML = svg("close");
        header.append(el("h2", "title", form.title), close);

        ui.progress = el("div", "progress");
        ui.progress.setAttribute("role", "progressbar");
        ui.progress.setAttribute("aria-label", "Fortschritt");
        ui.progress.setAttribute("aria-valuemin", "0");
        ui.progress.setAttribute("aria-valuemax", "100");
        ui.bar = ui.progress.appendChild(el("div", "progress-bar"));

        ui.slides = el("div", "slides");
        state.steps.forEach(function (step, index) {
          var slide = el("div", "slide");
          slide.setAttribute("role", "group");
          slide.setAttribute("aria-roledescription", "Schritt");
          slide.setAttribute("aria-label", (index + 1) + " von " + state.steps.length);

          if (step.type === "intro") {
            slide.append(el("h3", "question", form.title), el("p", "intro", form.intro));
          } else if (step.type === "question") {
            step.focus = renderQuestion(step, slide);
          } else if (step.type === "review") {
            step.content = slide.appendChild(el("div"));
            renderReview(step);
          } else {
            renderPrivacy(slide);
          }
          if (index === state.steps.length - 1) renderSubmitExtras(slide);
          ui.slides.appendChild(slide);
        });

        ui.slides.addEventListener("scroll", followScroll);
        if ("onscrollend" in window) {
          ui.slides.addEventListener("scrollend", function () {
            if (activeForm !== state) return;
            state.scrollTarget = null;
            followScroll();
          });
        }
        ui.slides.addEventListener("keydown", function (event) {
          if (event.key !== "Enter" || event.target.tagName === "BUTTON" || event.target.tagName === "A") return;
          if (event.target.tagName === "TEXTAREA" && !(event.ctrlKey || event.metaKey)) return;
          event.preventDefault();
          next();
        });

        var footer = el("div", "form-footer");
        ui.back = button("btn btn-secondary btn-icon", null, back);
        ui.back.setAttribute("aria-label", "Zurück");
        ui.back.innerHTML = svg("arrowLeft");
        ui.next = button("btn btn-primary", null, next);
        footer.append(ui.back, ui.next);

        state.node = el("div", "form");
        state.node.append(header, ui.progress, ui.slides, footer);
        updateChrome();
      }

      // Progress and buttons for the current step.
      function updateChrome() {
        var state = activeForm;
        var ui = state.ui;
        var step = state.steps[state.index];
        var last = state.index === state.steps.length - 1;

        Array.prototype.forEach.call(ui.slides.children, function (slide, index) {
          if (index === state.index) {
            slide.setAttribute("aria-current", "step");
          } else {
            slide.removeAttribute("aria-current");
          }
        });

        var percent = Math.round(state.index / state.steps.length * 100);
        ui.bar.style.width = percent + "%";
        ui.progress.setAttribute("aria-valuenow", String(percent));
        ui.back.hidden = state.index === 0;

        var label = "Weiter";
        if (last) {
          label = state.submitting ? "Wird gesendet …" : (state.form.submitLabel || "Absenden");
        } else if (step.type === "intro") {
          label = "Los geht’s";
        } else if (step.type === "question" && state.returnToReview) {
          label = "Zur Übersicht";
        }
        ui.next.replaceChildren(el("span", null, label));
        if (!last) ui.next.insertAdjacentHTML("beforeend", svg("arrowRight"));
        ui.next.disabled = state.submitting;
        if (ui.error) ui.error.textContent = state.error;
      }

      function setStep(index) {
        var state = activeForm;
        if (index === state.index) return;
        state.index = index;
        var step = state.steps[index];
        if (step.type === "review") {
          state.returnToReview = false;
          renderReview(step);
        }
        updateChrome();
      }

      function goTo(index, focus) {
        var state = activeForm;
        var slides = state.ui.slides;
        setStep(index);
        // Smooth scrolling passes the steps in between; they must not become the current step.
        state.scrollTarget = index;
        state.scrollUntil = Date.now() + 1000;
        slides.scrollTo({ left: index * slides.clientWidth, behavior: reducedMotion.matches ? "auto" : "smooth" });
        if (focus) focusStep();
      }

      var scrollFrame = null;

      // Swiping changes the current step.
      function followScroll() {
        if (scrollFrame) return;
        scrollFrame = window.requestAnimationFrame(function () {
          scrollFrame = null;
          var state = activeForm;
          if (!state || state.done) return;
          var slides = state.ui.slides;
          if (!slides.clientWidth) return;

          var index = Math.min(state.steps.length - 1, Math.round(Math.abs(slides.scrollLeft) / slides.clientWidth));
          if (state.scrollTarget !== null) {
            if (index !== state.scrollTarget && Date.now() < state.scrollUntil) return;
            state.scrollTarget = null;
          }
          setStep(index);
        });
      }

      // The panel is rebuilt when it opens again or the theme changes, which
      // loses the scroll position of the slides.
      function restoreScroll() {
        var state = activeForm;
        if (state.done) return;
        state.scrollTarget = null;
        state.ui.slides.scrollLeft = state.index * state.ui.slides.clientWidth;
      }

      function focusStep() {
        var state = activeForm;
        var target = (!state.done && state.steps[state.index].focus) || state.ui.next;
        target.focus({ preventScroll: true });
      }

      function renderQuestion(step, slide) {
        var state = activeForm;
        var question = step.question;
        var id = "kh-q" + question.id;
        var describedBy = [];

        slide.appendChild(el("p", "step-count", "Frage " + step.number + " von " + state.form.questions.length));
        var heading = slide.appendChild(el("h3", "question", question.label));
        heading.id = id + "-label";
        if (!question.required) heading.appendChild(el("span", "optional", " (optional)"));
        if (question.help) {
          slide.appendChild(el("p", "help", question.help)).id = id + "-help";
          describedBy.push(id + "-help");
        }

        step.error = el("p", "error");
        step.error.id = id + "-error";
        step.error.setAttribute("role", "alert");
        describedBy.push(step.error.id);

        var field = buildField(question, id);
        step.field = field.node;
        field.node.setAttribute("aria-labelledby", heading.id);
        field.node.setAttribute("aria-describedby", describedBy.join(" "));
        slide.append(field.node, step.error);

        return field.focus;
      }

      function buildField(question, id) {
        var answers = activeForm.answers;
        var value = answers[question.id];

        if (question.kind === "single_choice" || question.kind === "multiple_choice" || question.kind === "yes_no") {
          var multiple = question.kind === "multiple_choice";
          var group = el("div", "options");
          group.setAttribute("role", multiple ? "group" : "radiogroup");
          var inputs = (question.kind === "yes_no" ? ["Ja", "Nein"] : question.choices || []).map(function (choice) {
            var option = el("label", "option");
            var input = el("input");
            input.type = multiple ? "checkbox" : "radio";
            input.name = id;
            input.value = choice;
            input.checked = multiple ? (value || []).indexOf(choice) !== -1 : value === choice;
            input.addEventListener("change", function () {
              answers[question.id] = multiple
                ? Array.prototype.map.call(group.querySelectorAll("input:checked"), function (box) { return box.value; })
                : choice;
            });
            option.append(input, el("span", null, choice));
            group.appendChild(option);
            return input;
          });
          var checked = inputs.filter(function (input) { return input.checked; })[0];
          return { node: group, focus: checked || inputs[0] };
        }

        var field;
        if (question.kind === "long_text") {
          field = el("textarea", "input");
          field.rows = 5;
        } else {
          field = el("input", "input");
          field.type = INPUT_TYPES[question.kind] || "text";
          if (question.kind === "number") field.inputMode = "decimal";
          if (question.kind === "email") field.autocomplete = "email";
          if (question.kind === "phone") field.autocomplete = "tel";
        }
        field.id = id;
        if (question.maxLength) field.maxLength = question.maxLength;
        if (question.required) field.setAttribute("aria-required", "true");
        field.value = value || "";
        field.addEventListener("input", function () { answers[question.id] = field.value; });
        return { node: field, focus: field };
      }

      function renderReview(step) {
        var state = activeForm;

        step.content.replaceChildren(el("h3", "question", "Stimmt alles so?"), el("p", "help", "Prüfe deine Angaben, bevor du sie absendest."));

        var list = el("dl", "review");
        state.steps.forEach(function (other, index) {
          if (other.type !== "question") return;
          var question = other.question;
          var answer = formatAnswer(question, state.answers[question.id]);
          // Swiping skips the checks of the "Weiter" button.
          var message = validate(question, state.answers[question.id]);
          var item = el("div", "review-item");
          var text = el("div", "review-text");
          text.append(el("dt", "review-label", question.label), el("dd", "review-value" + (answer ? "" : " review-value--empty"), answer || "Keine Angabe"));
          if (message) text.appendChild(el("p", "error", message));
          var edit = button("edit", "Ändern", function () {
            state.returnToReview = true;
            state.error = "";
            goTo(index, true);
          });
          edit.setAttribute("aria-label", "Ändern: " + question.label);
          item.append(text, edit);
          list.appendChild(item);
        });
        step.content.appendChild(list);
      }

      function renderPrivacy(slide) {
        var state = activeForm;

        slide.append(el("h3", "question", "Datenschutz"), el("p", "help", "Bitte lies die folgenden Hinweise, bevor du deine Angaben absendest."));

        var privacyUrl = safeUrl(privacy.privacyUrl);
        var privacyLink = null;
        if (privacyUrl) {
          privacyLink = el("a", null, "Datenschutzerklärung");
          privacyLink.href = privacyUrl;
          privacyLink.target = "_blank";
          privacyLink.rel = "noopener";
        }

        if (privacy.consentText) {
          var consent = el("label", "consent");
          var box = state.ui.consent = el("input");
          box.type = "checkbox";
          box.addEventListener("change", function () { state.consent = box.checked; });
          var text = el("span", null, privacy.consentText);
          if (privacyLink) text.append(" (", privacyLink, ")");
          consent.append(box, text);
          slide.appendChild(consent);
        } else if (privacyLink) {
          var notice = el("p", "privacy", "Informationen zum Umgang mit deinen Daten findest du in unserer ");
          notice.append(privacyLink, ".");
          slide.appendChild(notice);
        }
      }

      // Honeypot and error message, on the step with the submit button.
      function renderSubmitExtras(slide) {
        var state = activeForm;

        // Honeypot: invisible for people, bots tend to fill it in.
        var trap = el("div", "hp");
        trap.setAttribute("aria-hidden", "true");
        var trapInput = el("input");
        trapInput.name = "website";
        trapInput.tabIndex = -1;
        trapInput.autocomplete = "off";
        trapInput.addEventListener("input", function () { state.honeypot = trapInput.value; });
        trap.appendChild(trapInput);
        slide.appendChild(trap);

        state.ui.error = el("p", "error");
        state.ui.error.setAttribute("role", "alert");
        slide.appendChild(state.ui.error);
      }

      function setFieldError(step, message) {
        var state = activeForm;
        if (message) {
          state.errors[step.question.id] = message;
          step.field.setAttribute("aria-invalid", "true");
        } else {
          delete state.errors[step.question.id];
          step.field.removeAttribute("aria-invalid");
        }
        step.error.textContent = message || "";
      }

      function checkStep(step) {
        var message = validate(step.question, activeForm.answers[step.question.id]);
        setFieldError(step, message);
        return !message;
      }

      function next() {
        var state = activeForm;
        if (state.done) return closeForm(false);

        var step = state.steps[state.index];
        if (step.type === "question" && !checkStep(step)) return step.focus.focus({ preventScroll: true });
        if (state.index === state.steps.length - 1) return submit();

        goTo(state.returnToReview && step.type === "question" ? state.reviewIndex : state.index + 1, true);
      }

      function back() {
        activeForm.returnToReview = false;
        activeForm.error = "";
        goTo(Math.max(0, activeForm.index - 1), true);
      }

      // Jumps to the first question the client or the server rejected.
      function showInvalidQuestion() {
        var state = activeForm;
        var index = state.steps.findIndex(function (step) { return step.type === "question" && state.errors[step.question.id]; });
        if (index === -1) return false;

        state.returnToReview = true;
        goTo(index, true);
        return true;
      }

      function submit() {
        var state = activeForm;
        var form = state.form;
        if (state.submitting) return;

        // Swiping skips the checks of the "Weiter" button, so every answer is checked again.
        state.steps.forEach(function (step) { if (step.type === "question") checkStep(step); });
        if (showInvalidQuestion()) return;

        if (privacy.consentText && !state.consent) {
          state.error = MESSAGES.consent;
          updateChrome();
          return state.ui.consent.focus({ preventScroll: true });
        }

        if (!endpoint) {
          state.preview = true;
          return showDone();
        }

        var body = new FormData();
        form.questions.forEach(function (question) {
          var value = state.answers[question.id];
          if (Array.isArray(value)) {
            value.forEach(function (item) { body.append("answers[" + question.id + "][]", item); });
          } else if (!isBlank(value)) {
            body.append("answers[" + question.id + "]", value);
          }
        });
        body.append("consent", state.consent ? "1" : "0");
        body.append("website", state.honeypot);
        body.append("elapsed_ms", String(Date.now() - state.startedAt));

        state.submitting = true;
        state.error = "";
        updateChrome();

        fetch(endpoint + "/forms/" + encodeURIComponent(form.id) + "/submissions", { method: "POST", body: body, credentials: "omit" })
          .then(function (response) {
            return response.json().catch(function () { return {}; }).then(function (json) { return { ok: response.ok, json: json }; });
          })
          .then(function (result) {
            if (activeForm !== state) return;
            state.submitting = false;
            var errors = result.json.errors || {};

            if (result.ok) return showDone();

            if (errors.consent) {
              state.error = errors.consent;
            } else if (Object.keys(errors).length) {
              state.steps.forEach(function (step) { if (step.type === "question") setFieldError(step, errors[step.question.id]); });
              if (showInvalidQuestion()) return;
              state.error = MESSAGES.network;
            } else {
              state.error = result.json.error || MESSAGES.network;
            }
            updateChrome();
          })
          .catch(function () {
            if (activeForm !== state) return;
            state.submitting = false;
            state.error = MESSAGES.network;
            updateChrome();
          });
      }

      // The thank-you message takes the place of the slides.
      function showDone() {
        var state = activeForm;
        var ui = state.ui;
        state.done = true;

        var done = el("div", "done");
        done.innerHTML = svg("check");
        done.append(el("h3", "question", "Vielen Dank!"), el("p", "intro", state.form.thankYou || "Wir haben deine Angaben erhalten."));
        if (state.preview) done.appendChild(el("p", "help", "Vorschau: Es wurde nichts gesendet."));
        ui.slides.replaceWith(done);

        ui.bar.style.width = "100%";
        ui.progress.setAttribute("aria-valuenow", "100");
        ui.back.hidden = true;
        ui.next.replaceChildren(el("span", null, "Schließen"));
        ui.next.disabled = false;
        ui.next.focus();
      }

      // Keep keyboard focus inside the form dialog on the public hub page.
      formLayer.addEventListener("keydown", function (event) {
        if (event.key !== "Tab") return;
        var focusable = Array.prototype.filter.call(formLayer.querySelectorAll("button, input, textarea, a[href]"), function (node) {
          return !node.disabled && node.tabIndex !== -1;
        });
        if (!focusable.length) return;
        var first = focusable[0];
        var last = focusable[focusable.length - 1];
        if (event.shiftKey && root.activeElement === first) {
          last.focus();
          event.preventDefault();
        } else if (!event.shiftKey && root.activeElement === last) {
          first.focus();
          event.preventDefault();
        }
      });

      var fullscreen = window.matchMedia("(max-width: 640px)");
      var previousOverflow = null;

      function lockScroll() {
        var lock = !options.container && ((headless && !!activeForm) || (open && fullscreen.matches));
        var html = document.documentElement;
        if (lock && previousOverflow === null) {
          previousOverflow = html.style.overflow;
          html.style.overflow = "hidden";
        } else if (!lock && previousOverflow !== null) {
          html.style.overflow = previousOverflow;
          previousOverflow = null;
        }
      }

      if (fullscreen.addEventListener) fullscreen.addEventListener("change", lockScroll);

      function toggle(value, focus) {
        if (open === value) return;
        open = value;
        lockScroll();
        render();
        if (!focus) return;
        var target = open ? root.querySelector(".link, .close") : root.querySelector(".button");
        if (target) target.focus();
      }

      document.addEventListener("keydown", function (event) {
        if (event.key !== "Escape" || !host.isConnected) return;
        if (activeForm && (headless || open)) {
          closeForm(true);
        } else if (open) {
          toggle(false, true);
        }
      });

      document.addEventListener("click", function (event) {
        if (open && !activeForm && !options.container && host.isConnected && event.composedPath().indexOf(host) === -1) toggle(false, false);
      });

      if (headless) {
        document.addEventListener("click", function (event) {
          var trigger = event.target.closest && event.target.closest("[data-kirchen-hub-form]");
          if (!trigger || activeForm || !host.isConnected) return;
          var item = data.links.filter(function (link) {
            return link.form && String(link.form.id) === trigger.getAttribute("data-kirchen-hub-form");
          })[0];
          if (!item) return;
          event.preventDefault();
          openForm(item.form, trigger);
        });
      }

      host.addEventListener("kirchen-hub:update", function (event) {
        Object.assign(theme, event.detail.theme || {});
        if (event.detail.title) data.title = event.detail.title;
        render();
      });

      render();
    }
  }

  window.KirchenHub = { mount: mount };
})();
