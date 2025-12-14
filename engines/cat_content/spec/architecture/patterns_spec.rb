# frozen_string_literal: true

require "spec_helper"
require "rampart"
require "rampart/testing"
require "active_record"

ENGINE_ROOT = File.expand_path("../..", __dir__)
require File.join(ENGINE_ROOT, "app/domain/cat_content/types.rb")
value_object_files = %w[
  cat_id.rb
  cat_media.rb
  cat_name.rb
  trait_set.rb
  cat_profile.rb
  content_block.rb
  money.rb
  paginated_result.rb
  slug.rb
  tag_list.rb
  visibility.rb
]
value_object_files.each do |file|
  require File.join(ENGINE_ROOT, "app/domain/cat_content/value_objects", file)
end
Dir[File.join(ENGINE_ROOT, "app/domain/cat_content/entities/**/*.rb")].sort.each { |file| require file }
Dir[File.join(ENGINE_ROOT, "app/domain/cat_content/aggregates/**/*.rb")].sort.each { |file| require file }
Dir[File.join(ENGINE_ROOT, "app/domain/cat_content/ports/**/*.rb")].sort.each { |file| require file }
Dir[File.join(ENGINE_ROOT, "app/domain/cat_content/services/**/*.rb")].sort.each { |file| require file }
Dir[File.join(ENGINE_ROOT, "app/application/cat_content/**/*.rb")].sort.each { |file| require file }
Dir[File.join(ENGINE_ROOT, "app/infrastructure/cat_content/persistence/**/*.rb")].sort.each { |file| require file }

RSpec.describe "Architecture::Patterns", type: :architecture, skip_db: true do
  let(:aggregates) { [CatContent::Aggregates::CatListing] }

  let(:value_objects) do
    CatContent::ValueObjects.constants(false)
                             .map { |name| CatContent::ValueObjects.const_get(name) }
                             .select { |const| const.is_a?(Class) }
  end

  let(:ports) { [CatContent::Ports::CatListingRepository] }
  let(:port_implementations) { [CatContent::Infrastructure::Persistence::Repositories::SqlCatListingRepository] }
  let(:queries) { [CatContent::Queries::ListCatListingsQuery] }
  let(:commands) { [] }

  it "keeps aggregates on Rampart base classes" do
    expect(aggregates).to all(inherit_from_rampart_base(Rampart::Domain::AggregateRoot))
    expect(aggregates).to all(have_no_rails_dependencies)
    expect(aggregates).to all(be_immutable)
  end

  it "keeps value objects immutable and on Rampart base class" do
    expect(value_objects).to all(inherit_from_rampart_base(Rampart::Domain::ValueObject))
    expect(value_objects).to all(have_no_rails_dependencies)
    expect(value_objects).to all(be_immutable)
  end

  it "keeps ports on Rampart base class and implemented" do
    expect(ports).to all(inherit_from_rampart_base(Rampart::Ports::SecondaryPort))
    expect(ports).to all(have_no_rails_dependencies)

    ports.each do |port|
      implementations = port_implementations.select { |impl| impl < port }
      expect(implementations).not_to be_empty, "expected #{port} to have at least one implementation"

      implementations.each do |implementation|
        expect(implementation).to implement_all_abstract_methods(port)
      end
    end
  end

  it "keeps CQRS DTOs on Rampart base classes" do
    expect(queries).to all(inherit_from_rampart_base(Rampart::Application::Query))
    expect(commands).to all(inherit_from_rampart_base(Rampart::Application::Command))
  end

  describe CatContent::Infrastructure::Persistence::Repositories::SqlCatListingRepository do
    let(:mapper) { instance_double(CatContent::Infrastructure::Persistence::Mappers::CatListingMapper) }
    let(:repository) { described_class.new(mapper: mapper) }
    let(:record) { instance_double(CatListingRecord) }
    let(:aggregate) { instance_double(CatContent::Aggregates::CatListing) }

    it "maps records to domain aggregates on find" do
      allow(CatListingRecord).to receive(:find_by).and_return(record)
      allow(mapper).to receive(:to_domain).with(record).and_return(aggregate)

      expect(repository.find("id")).to eq(aggregate)
    end

    it "returns paginated domain value objects on list_public" do
      relation = instance_double("Relation")
      allow(CatListingRecord).to receive(:where).with(visibility: "public").and_return(relation)
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
end
