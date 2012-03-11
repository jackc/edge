module Edge
  module Forest
    module ClassMethods
      def acts_as_forest(options={})
        options.assert_valid_keys :foreign_key, :order
        
        class_attribute :forest_foreign_key
        self.forest_foreign_key = options[:foreign_key] || "parent_id"
        
        class_attribute :forest_order
        self.forest_order = options[:order] || nil
                
        common_options = {
          :class_name => self,
          :foreign_key => forest_foreign_key
        }
      
        belongs_to :parent, common_options
          
        children_options = if forest_order
          common_options.merge(:order => forest_order)
        else
          common_options
        end
        
        has_many :children, children_options
        
        scope :root, where(forest_foreign_key => nil)
        
        include Edge::Forest::InstanceMethods
        
        def find_forest
          all_nodes = Arel::Table.new(:all_nodes)
              
          original_term = (current_scope || scoped).arel
          iterated_term = Arel::SelectManager.new Arel::Table.engine
          iterated_term.from(arel_table)
            .project(arel_table.columns)
            .join(all_nodes)
            .on(arel_table[forest_foreign_key].eq all_nodes[:id])
          
          union = original_term.union(iterated_term)
          
          as_statement = Arel::Nodes::As.new all_nodes, union
          
          manager = Arel::SelectManager.new Arel::Table.engine
          manager.with(:recursive, as_statement).from(all_nodes).project(Arel.star)
          manager.order(forest_order) if forest_order
          
          records = find_by_sql manager.to_sql

          records_by_id = records.each_with_object({}) { |r, h| h[r.id] = r }

          # Set all children associations to an empty array
          records.each do |r|
            children_association = r.association(:children)
            children_association.target = []
          end

          top_level_records = []
          
          records.each do |r|
            parent = records_by_id[r[forest_foreign_key]]
            if parent
              r.association(:parent).target = parent
              parent.association(:children).target.push(r)
            else
              top_level_records.push(r)
            end
          end
          
          top_level_records
        end
        
        def find_tree(id_or_ids)
          trees = where(:id => id_or_ids).find_forest
          if id_or_ids.kind_of?(Array)
            raise ActiveRecord::RecordNotFound unless trees.size == id_or_ids.size
            trees
          else
            raise ActiveRecord::RecordNotFound if trees.empty?
            trees.first
          end
        end
      end      
    end
    
    module InstanceMethods
      def root
        parent ? parent.root : self
      end
      
      def root?
        !parent_id
      end
      
      def siblings
        parent ? parent.children - [self] : []
      end
      
      def ancestors
        _ancestors = []
        node = self
        while(node = node.parent)
          _ancestors.push(node)
        end
        
        _ancestors
      end
      
      def descendants
        if children.present?
          children + children.map(&:descendants).flatten
        else
          []
        end    
      end
    end
  end
end

ActiveRecord::Base.extend Edge::Forest::ClassMethods
