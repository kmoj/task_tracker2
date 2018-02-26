defmodule TaskTrackerWeb.Router do
  use TaskTrackerWeb, :router

  pipeline :browser do
    import TaskTrackerWeb.Plugs
    plug :accepts, ["html"]
    plug :fetch_session
    plug :get_current_user
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TaskTrackerWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/profile", PageController, :profile
    get "/assigns", PageController, :assigns

    resources "/users", UserController
    resources "/tasks", TaskController

    post "/session", SessionController, :create
    delete "/session", SessionController, :delete
  end

  # Other scopes may use custom stacks.
   scope "/api/v1", TaskTrackerWeb do
     pipe_through :api
     resources "/manages", ManageController, expect: [:new, :edit]
     resources "/timeblocks", TimeblockController, expect: [:new, :edit]
   end
end
