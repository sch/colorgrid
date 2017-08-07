exports.config = {
  files: {
    stylesheets: {
      joinTo: "css/app.css"
    },
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to "/assets/static". Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(static)/
  },

  paths: {
    watched: ["elm", "static", "css", "js", "vendor"],
    public: "../priv/static"
  },

  plugins: {
    babel: {
      ignore: [/vendor/]
    },

    elmBrunch: {
      mainModules: ["elm/Phone.elm", "elm/Controller.elm"]
    }
  },

  npm: {
    enabled: true
  }
};
