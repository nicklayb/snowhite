var __defProp = Object.defineProperty;
var __markAsModule = (target) => __defProp(target, "__esModule", { value: true });
var __export = (target, all) => {
  __markAsModule(target);
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};

// js/snowhite/index.js
__export(exports, {
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
var withHooks = (hooks) => ({
  ...hooks_exports,
  ...hooks
});
//# sourceMappingURL=snowhite.cjs.js.map
