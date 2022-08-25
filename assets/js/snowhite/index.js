import * as Hooks from './hooks'

export const withHooks = (hooks) => ({
  ...Hooks,
  ...hooks,
})

export { Hooks }
