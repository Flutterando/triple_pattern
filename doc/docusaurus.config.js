const lightCodeTheme = require('prism-react-renderer/themes/github');
const darkCodeTheme = require('prism-react-renderer/themes/dracula');

/** @type {import('@docusaurus/types').DocusaurusConfig} */
module.exports = {
  title: 'Triple',
  tagline: 'Segmented State Pattern',
  url: 'https://triplepattern.netlify.app',
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
        alt: 'Triple Pattern',
        src: 'img/logo.svg',
      },
      items: [
        {
          type: 'doc',
          docId: 'intro',
          position: 'left',
          label: 'SSP',
        },
        {
          type: 'doc',
          docId: 'getting-started/what-is-triple',
          position: 'left',
          label: 'Getting Started',
        },
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
              label: 'Segmented State Pattern (SSP)',
              to: '/docs/intro',
            },
            {
              label: 'Getting Started',
              to: '/docs/getting-started/what-is-triple',
            },
          ],
        },
        {
          title: 'Community',
          items: [
            {
              label: 'Flutterando',
              href: 'https://stackoverflow.com/questions/tagged/docusaurus',
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
      copyright: `Copyright © 2022 Flutterando, Inc. Built with Docusaurus.`,
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
            'https://github.com/facebook/docusaurus/edit/master/website/',
        },
        blog: {
          showReadingTime: true,
          // Please change this to your repo.
          editUrl:
            'https://github.com/facebook/docusaurus/edit/master/website/blog/',
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      },
    ],
  ],
};
