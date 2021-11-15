const defaultTheme = require('tailwindcss/defaultTheme');

module.exports = {
  darkMode: false, // or 'media' or 'class'
  mode: 'jit',
  purge: [
    './js/**/*.js',
    '../lib/*_web/**/*.*ex'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  variants: {},
  plugins: []
};