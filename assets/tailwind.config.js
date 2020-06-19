module.exports = {
  purge: [
    '../**/*.html.eex',
  ],
  theme: {
    fontFamily: {
      display: ['Special Elite', 'cursive'],
    },
    extend: {
      height: {
        '96': '24rem',
        'screen-60': '60vh',
        'screen-70': '70vh',
      }
    },
  },
  variants: {
    backgroundColor: ['responsive', 'hover', 'focus', 'active'],
    textColor: ['responsive', 'hover', 'focus', 'active'],
  },
  plugins: [],
}
