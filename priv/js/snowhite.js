var Snowhite = (() => {
  var __defProp = Object.defineProperty;
  var __getOwnPropSymbols = Object.getOwnPropertySymbols;
  var __hasOwnProp = Object.prototype.hasOwnProperty;
  var __propIsEnum = Object.prototype.propertyIsEnumerable;
  var __defNormalProp = (obj, key, value) => key in obj ? __defProp(obj, key, { enumerable: true, configurable: true, writable: true, value }) : obj[key] = value;
  var __spreadValues = (a, b) => {
    for (var prop in b || (b = {}))
      if (__hasOwnProp.call(b, prop))
        __defNormalProp(a, prop, b[prop]);
    if (__getOwnPropSymbols)
      for (var prop of __getOwnPropSymbols(b)) {
        if (__propIsEnum.call(b, prop))
          __defNormalProp(a, prop, b[prop]);
      }
    return a;
  };
  var __markAsModule = (target) => __defProp(target, "__esModule", { value: true });
  var __export = (target, all) => {
    __markAsModule(target);
    for (var name in all)
      __defProp(target, name, { get: all[name], enumerable: true });
  };

  // js/snowhite/index.js
  var snowhite_exports = {};
  __export(snowhite_exports, {
    Hooks: () => hooks_exports,
    withHooks: () => withHooks
  });

  // js/snowhite/hooks/index.js
  var hooks_exports = {};
  __export(hooks_exports, {
    SnowhiteClock: () => Clock_default
  });

  // js/snowhite/hooks/Clock.js
  var Clock = {
    mounted() {
    }
  };
  var Clock_default = Clock;

  // js/snowhite/index.js
  var withHooks = (hooks) => __spreadValues(__spreadValues({}, hooks_exports), hooks);
  return snowhite_exports;
})();
