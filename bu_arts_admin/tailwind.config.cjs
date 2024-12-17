/** @type {import('tailwindcss').Config} */
// export default {
//   content: [],
//   theme: {
//     extend: {},
//   },
//   plugins: [],
// }
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}", // Specify paths to your components and pages
  ],
  theme: {
    extend: {
      colors: {
        'bured': '#CC0000',
        'sidebar-grey': '#3A3541',
        'sidebar-red': '#CC0000',
      },
    },
  },
  plugins: [require('@tailwindcss/typography'),],
};
