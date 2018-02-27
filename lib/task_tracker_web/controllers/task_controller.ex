defmodule TaskTrackerWeb.TaskController do
  use TaskTrackerWeb, :controller

  alias TaskTracker.Job
  alias TaskTracker.Job.Task
  alias TaskTracker.Account
  alias TaskTracker.Account.Manage
  alias TaskTracker.Accounts
  alias TaskTracker.Accounts.User
  alias TaskTracker.Job.Timeblock

  def index(conn, _params) do
    tasks = Job.list_tasks()
    changeset = Job.change_task(%Task{})
    render(conn, "index.html", tasks: tasks, changeset: changeset)
  end

  def new(conn, _params) do
    changeset = Job.change_task(%Task{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"task" => task_params}) do

    title = task_params["assigned_to"]
    description = task_params["description"]
    assigned_to = task_params["assigned_to"]
    flag = false
    error_msg = nil


    if title !== "" && description !== "" && assigned_to !== "" do
      if (Accounts.get_user_by_name(assigned_to)) do
        flag = true
      else
        error_msg = "User assigned to is not found"
      end
    else
      error_msg = "Please fill in all blanks"
    end

    if flag do
      case Job.create_task(task_params) do
        {:ok, task} ->
          conn
          |> put_flash(:info, "Task created successfully.")
          |> redirect(to: task_path(conn, :index))
        {:error, %Ecto.Changeset{} = changeset} ->
          #render(conn, "index.html", task: nil, changeset: changeset)
          conn
          |> put_flash(:error, "something went wrong")
          |> redirect(to: task_path(conn, :index), changeset: changeset)
      end
    else
      conn
      |> put_flash(:error, "Error: #{error_msg}")
      |> redirect(to: task_path(conn, :index))
    end
  end

  def show(conn, %{"id" => id}) do
    task = Job.get_task!(id)
    time_blocks = Job.get_timeblock_by_task_id(id)
    render(conn, "show.html", task: task, time_blocks: time_blocks)
  end

  def edit(conn, %{"id" => id}) do
    task = Job.get_task!(id)
    changeset = Job.change_task(task)
    render(conn, "edit.html", task: task, changeset: changeset)
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    current_user = conn.assigns[:current_user]
    task = Job.get_task!(id)

    assigned_to = task_params["assigned_to"]
    assignee = Accounts.get_user_by_name(assigned_to)
    managees = Account.get_managee_user(current_user)
    managee_users = Account.get_managee_user(current_user)
    |> Enum.map(fn(x)-> Accounts.get_user!(x.managee_id) end)
    time = 0
    flag = false
    error_msg = nil

    if Accounts.get_user_by_name(assigned_to) do
      if Enum.member?(managee_users, assignee) || assignee == current_user do
        if time >= 0 do
            flag = true
        else
            error_msg = "invalid time input"
        end
      else
        error_msg = "the assignee: #{assignee.name} is not under your management"
      end
    else
      error_msg = "user not found"
    end

    if flag do
#      task_params = Map.update!(task_params, "time", fn(x) -> 0  end)
      case Job.update_task(task, task_params) do
        {:ok, task} ->
          conn
         #|> put_flash(:info, "Task updated successfully.")
          |> redirect(to: task_path(conn, :show, task))
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", task: task, changeset: changeset)
      end
    else
      conn
      |> put_flash(:error, "Error: #{error_msg}")
      |> redirect(to: task_path(conn, :edit, task))
    end

  end

  def delete(conn, %{"id" => id}) do
    task = Job.get_task!(id)
    {:ok, _task} = Job.delete_task(task)

    conn
    |> put_flash(:info, "Task deleted successfully.")
    |> redirect(to: task_path(conn, :index))
  end
end
