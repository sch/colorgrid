**Sync a color across as many phones as will fit on a free heroku instance**

To build the front-end, run `npm install && npm run build`. To serve the app,
run `mix deps.get && mix deps.compile && iex -S mix` and visit:

- [localhost:4000/](http://localhost:4000/) for the follower page
- [localhost:4000/control](http://localhost:4000/control) for the color-select
  leader page
