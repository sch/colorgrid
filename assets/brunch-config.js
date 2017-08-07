exports.config = {
  files: {
    javascripts: {
      joinTo: "js/app.js"
    },
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
    elmBrunch: {
      mainModules: ["elm/Leader.elm", "elm/Follower.elm"]
    }
  },

  npm: {
    enabled: true
  }
};
