const SECOND = 1000

const padPart = part => part.toString().padStart(2, "0")

const getDate = () => {
  const date = new Date()

  return [date.getHours(), padPart(date.getMinutes()), padPart(date.getSeconds())].join(":")
}

const Clock = {
  mounted() {
    this.setupTimeout()
  },
  updated() {
    if (this.timer) {
      clearTimeout(this.timer)
      this.timer = null
      this.setupTimeout()
    }
  },
  handleTick() {
    this.el.querySelector(".time").innerHTML = getDate()

    this.setupTimeout()
  },
  setupTimeout() {
    const timer = setTimeout(this.handleTick.bind(this), SECOND)
    this.timer = timer
  }
}

export default Clock
