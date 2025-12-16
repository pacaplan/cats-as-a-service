require "rails_helper"

RSpec.describe CatContent::Infrastructure::Persistence::Repositories::SqlCatListingRepository do
  let(:mapper) { instance_double(CatContent::Infrastructure::Persistence::Mappers::CatListingMapper) }
  let(:repository) { described_class.new(mapper: mapper) }
  let(:record) { instance_double(CatContent::CatListingRecord) }
  let(:aggregate) { instance_double(CatContent::Aggregates::CatListing) }

  it "maps records to domain aggregates on find" do
    allow(CatContent::CatListingRecord).to receive(:find_by).and_return(record)
    allow(mapper).to receive(:to_domain).with(record).and_return(aggregate)

    expect(repository.find("id")).to eq(aggregate)
  end

  it "returns paginated domain value objects on list_public" do
    relation = instance_double("Relation")
    allow(CatContent::CatListingRecord).to receive(:where).with(visibility: "public").and_return(relation)
    allow(relation).to receive(:where).and_return(relation)
    allow(relation).to receive(:count).and_return(1)
    allow(relation).to receive(:order).and_return(relation)
    allow(relation).to receive(:offset).and_return(relation)
    allow(relation).to receive(:limit).and_return([record])

    allow(mapper).to receive(:to_domain).with(record).and_return(aggregate)

    result = repository.list_public(tags: [], page: 1, per_page: 10)

    expect(result).to be_a(CatContent::ValueObjects::PaginatedResult)
    expect(result.items).to all(eq(aggregate))
  end
end

