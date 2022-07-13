# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.Pagination.MarketListing do
  use Chunkr.PaginationPlanner

  paginate_by :default do
    sort :desc, as(:listing).id
  end

  paginate_by :level do
    sort :asc, as(:pokemon).level
    sort :desc, as(:listing).id
  end

  paginate_by :species do
    sort :asc, as(:variant).species_id
    sort :desc, as(:listing).id
  end

  paginate_by :iv_total do
    sort :asc,
         as(:pokemon).iv_hp + as(:pokemon).iv_atk +
           as(:pokemon).iv_def + as(:pokemon).iv_satk +
           as(:pokemon).iv_sdef + as(:pokemon).iv_spd

    sort :desc, as(:listing).id
  end

  paginate_by :listing_price do
    sort :asc, as(:listing).price
    sort :desc, as(:listing).id
  end
end
