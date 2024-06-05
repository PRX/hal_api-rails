require "hal_api/representer/collection_paging"

class HalApi::PagedCollectionRepresenter < HalApi::Representer
  include HalApi::Representer::CollectionPaging
end
