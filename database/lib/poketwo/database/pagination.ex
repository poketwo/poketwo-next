# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.Pagination do
  use Chunkr.PaginationPlanner

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
