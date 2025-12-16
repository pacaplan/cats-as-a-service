# frozen_string_literal: true

module CatContent
  module Infrastructure
    module Persistence
      module Repositories
        class SqlCustomCatRepository < Ports::CustomCatRepository
          def initialize(mapper: Mappers::CustomCatMapper.new)
            @mapper = mapper
          end

          def add(aggregate)
            rec = @mapper.to_record(aggregate)
            rec.save!
            aggregate
          end

          def find(id)
            rec = CatContent::CustomCatRecord.find_by(id: id.to_s)
            return nil unless rec
            begin
              @mapper.to_domain(rec)
            rescue => e
              puts "MAPPER ERROR: #{e.message}"
              puts e.backtrace.take(5)
              raise e
            end
          end

          def find_by_user_and_id(user_id:, id:)
             rec = CatContent::CustomCatRecord.find_by(user_id: user_id, id: id.to_s)
             rec && @mapper.to_domain(rec)
          end

          def list_all(filters: {}, page: 1, per_page: 20)
            scope = ::CatContent::CustomCatRecord.all
            
            if filters[:visibility]
              scope = scope.where(visibility: filters[:visibility])
            end

            total = scope.count
            records = scope.order(created_at: :desc)
                        .offset((page - 1) * per_page)
                        .limit(per_page)
            
            items = records.map { |r| @mapper.to_domain(r) }

            ValueObjects::PaginatedResult.new(
              items: items,
              total_count: total,
              page: page.to_i,
              per_page: per_page.to_i
            )
          end

          def list_by_user(user_id:, page: 1, per_page: 20, include_archived: false)
            scope = CatContent::CustomCatRecord.where(user_id: user_id)
            scope = scope.where.not(visibility: "archived") unless include_archived
            
            total = scope.count
            records = scope.offset((page - 1) * per_page).limit(per_page).order(created_at: :desc)
            
            items = records.map { |r| @mapper.to_domain(r) }
            
            ValueObjects::PaginatedResult.new(
              items: items,
              total_count: total,
              page: page.to_i,
              per_page: per_page.to_i
            )
          end



          def update(aggregate)
            add(aggregate)
          end

          def remove(id)
            CatContent::CustomCatRecord.where(id: id.to_s).delete_all
          end
        end
      end
    end
  end
end
