const lightCodeTheme = require('prism-react-renderer/themes/github');
const darkCodeTheme = require('prism-react-renderer/themes/dracula');

/** @type {import('@docusaurus/types').DocusaurusConfig} */
module.exports = {
  title: 'Triple',
  tagline: 'Segmented State Pattern',
  url: 'https://triple.flutterando.com.br',
  baseUrl: '/',
  onBrokenLinks: 'warn',
  // onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',
  favicon: 'img/favicon.ico',
  organizationName: 'flutterando', // Usually your GitHub org/user name.
  projectName: 'triple_pattern', // Usually your repo name.


  themeConfig: {
    navbar: {
      title: 'Triple',
      logo: {
        alt: 'Triple Logo',
        src: 'img/logo.svg',
      },
      items: [
       
        {
          href: 'https://github.com/Flutterando/triple_pattern',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            {
              label: 'Introduction',
              to: 'docs/intro/overview',
            },
            {
              label: 'Getting Started',
              to: 'docs/intro/getting-started',
            },

            
            
          ],
        },
        {
          title: 'Community',
          items: [
            {
              label: 'Flutterando',
              href: 'https://flutterando.com.br',
            },
            {
              label: 'Discord',
              href: 'https://discord.com/invite/x7X4uA9',
            },
            {
              label: 'Telegram',
              href: 'https://t.me/flutterando',
            },
          ],
        },
        {
          title: 'More',
          items: [
            {
              label: 'Medium Flutterando',
              href: 'https://medium.com/flutterando',
            },
            {
              label: 'GitHub',
              href: 'https://github.com/Flutterando/triple_pattern',
            },
          ],
        },
      ],
      copyright: `Copyright © 2023 Flutterando, Inc. Built with Docusaurus.`,
    },
    prism: {
      theme: lightCodeTheme,
      darkTheme: darkCodeTheme,
      additionalLanguages: ['dart', 'yaml'],
    },
  },
  presets: [
    [
      '@docusaurus/preset-classic',
      {
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          // Please change this to your repo.
          editUrl:
            'https://github.com/Flutterando/triple_pattern/blob/master/doc/',
        },
        blog: {
          showReadingTime: true,
          // Please change this to your repo.
          editUrl:
            'https://github.com/Flutterando/triple_pattern/blob/master/doc/blog/',
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      },
    ],
  ],
};
