var __defProp = Object.defineProperty;
var __markAsModule = (target) => __defProp(target, "__esModule", { value: true });
var __export = (target, all) => {
  __markAsModule(target);
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};

// js/snowhite/hooks/index.js
var hooks_exports = {};
__export(hooks_exports, {
  SnowhiteClock: () => Clock_default
});

// js/snowhite/hooks/Clock.js
var SECOND = 1e3;
var padPart = (part) => part.toString().padStart(2, "0");
var getDate = () => {
  const date = new Date();
  return [date.getHours(), padPart(date.getMinutes()), padPart(date.getSeconds())].join(":");
};
var Clock = {
  mounted() {
    this.setupTimeout();
  },
  updated() {
    if (this.timer) {
      clearTimeout(this.timer);
      this.timer = null;
      this.setupTimeout();
    }
  },
  handleTick() {
    this.el.querySelector(".time").innerHTML = getDate();
    this.setupTimeout();
  },
  setupTimeout() {
    const timer = setTimeout(this.handleTick.bind(this), SECOND);
    this.timer = timer;
  }
};
var Clock_default = Clock;

// js/snowhite/index.js
var withHooks = (hooks) => ({
  ...hooks_exports,
  ...hooks
});
export {
  hooks_exports as Hooks,
  withHooks
};
//# sourceMappingURL=snowhite.mjs.map
