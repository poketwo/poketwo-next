# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.Pagination do
  use Chunkr.PaginationPlanner
  use GenServer
  alias Poketwo.Database.Repo

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def begin(queryable, strategy, sort_dir, opts) do
    with key <- GenServer.call(__MODULE__, {:put, queryable, strategy, sort_dir}),
         {:ok, page} <- Repo.paginate(queryable, strategy, sort_dir, opts) do
      {:ok, key, page}
    end
  end

  def continue(key, opts) do
    with [{^key, queryable, strategy, sort_dir} | _] <- :ets.lookup(:pagination_queries, key),
         {:ok, page} <- Repo.paginate(queryable, strategy, sort_dir, opts) do
      {:ok, key, page}
    end
  end

  # Callbacks

  @impl true
  def init(opts) do
    ttl = Keyword.get(opts, :ttl, 1000 * 60 * 5)
    :ets.new(:pagination_queries, [:set, :protected, :named_table])
    {:ok, {0, ttl}}
  end

  @impl true
  def handle_call({:put, queryable, strategy, sort_dir}, _from, {key, ttl}) do
    :ets.insert(:pagination_queries, {key, queryable, strategy, sort_dir})
    Process.send_after(self(), {:invalidate, key}, ttl)
    {:reply, key, {key + 1, ttl}}
  end

  @impl true
  def handle_info({:invalidate, key}, state) do
    :ets.delete(:pagination_queries, key)
    {:noreply, state}
  end

  # Pagination Planner

  paginate_by :default do
    sort :asc, as(:pokemon).id
  end

  paginate_by :idx do
    sort :asc, as(:pokemon).id
  end

  paginate_by :level do
    sort :asc, as(:pokemon).level
    sort :asc, as(:pokemon).id
  end

  paginate_by :species do
    sort :asc, as(:variant).species_id
    sort :asc, as(:pokemon).id
  end

  paginate_by :iv_total do
    sort :asc,
         as(:pokemon).iv_hp + as(:pokemon).iv_atk +
           as(:pokemon).iv_def + as(:pokemon).iv_satk +
           as(:pokemon).iv_sdef + as(:pokemon).iv_spd

    sort :asc, as(:pokemon).id
  end
end
