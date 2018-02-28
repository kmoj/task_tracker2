defmodule TaskTrackerWeb.TimeblockController do
  use TaskTrackerWeb, :controller

  alias TaskTracker.Job
  alias TaskTracker.Job.Task
  alias TaskTracker.Job.Timeblock

  action_fallback TaskTrackerWeb.FallbackController

  def index(conn, _params) do
    timeblocks = Job.list_timeblocks()
    render(conn, "index.json", timeblocks: timeblocks)
  end

  def create(conn, %{"timeblock" => timeblock_params}) do
    with {:ok, %Timeblock{} = timeblock} <- Job.create_timeblock(timeblock_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", timeblock_path(conn, :show, timeblock))
      |> render("show.json", timeblock: timeblock)
    end
  end

  def show(conn, %{"id" => id}) do
    timeblock = Job.get_timeblock!(id)
    render(conn, "show.json", timeblock: timeblock)
  end

  def update(conn, %{"id" => id, "timeblock" => timeblock_params}) do
    timeblock = Job.get_timeblock!(id)
    task = Job.get_task!(timeblock.task_id)
    changeset = Job.change_task(task)
    old_t1 = timeblock.start
    old_t2 = timeblock.end
    {:ok, newt1} = NaiveDateTime.from_iso8601(timeblock_params["start"])
    {:ok, newt2} = NaiveDateTime.from_iso8601(timeblock_params["end"])

    old_diff = NaiveDateTime.diff(old_t2, old_t1, :second)
    old_diff = div(old_diff, 60)
    new_diff = NaiveDateTime.diff(newt2, newt1, :second)
    new_diff = div(new_diff, 60)

    task1 = Ecto.Changeset.change task, time: new_diff - old_diff + task.time


    Job.update_task(task, task1.changes)


    with {:ok, %Timeblock{} = timeblock} <- Job.update_timeblock(timeblock, timeblock_params) do
      render(conn, "show.json", timeblock: timeblock)
    end
  end

  def delete(conn, %{"id" => id}) do
    timeblock = Job.get_timeblock!(id)
    task = Job.get_task!(timeblock.task_id)
    changeset = Job.change_task(task)
    old_t1 = timeblock.start
    old_t2 = timeblock.end

    old_diff = NaiveDateTime.diff(old_t2, old_t1, :second)
    old_diff = div(old_diff, 60)

    task1 = Ecto.Changeset.change task, time: task.time - old_diff
    Job.update_task(task, task1.changes)

    with {:ok, %Timeblock{}} <- Job.delete_timeblock(timeblock) do
      send_resp(conn, :no_content, "")
    end
  end
end
