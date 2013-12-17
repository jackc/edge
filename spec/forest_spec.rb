require 'spec_helper'

class Location < ActiveRecord::Base
  acts_as_forest :order => "name"
end

Location.delete_all

describe "Edge::Forest" do
  let!(:usa) { Location.create! :name => "USA" }
  let!(:illinois) { Location.create! :parent => usa, :name => "Illinois" }
  let!(:chicago) { Location.create! :parent => illinois, :name => "Chicago" }
  let!(:indiana) { Location.create! :parent => usa, :name => "Indiana" }
  let!(:canada) { Location.create! :name => "Canada" }
  let!(:british_columbia) { Location.create! :parent => canada, :name => "British Columbia" }

  describe "root?" do
    context "of root node" do
      it "should be true" do
        usa.root?.should == true
      end
    end

    context "of child node" do
      it "should be false" do
        illinois.root?.should == false
      end
    end

    context "of leaf node" do
      it "should be root node" do
        chicago.root?.should == false
      end
    end
  end

  describe "root" do
    context "of root node" do
      it "should be self" do
        usa.root.should == usa
      end
    end

    context "of child node" do
      it "should be root node" do
        illinois.root.should == usa
      end
    end

    context "of leaf node" do
      it "should be root node" do
        chicago.root.should == usa
      end
    end
  end

  describe "parent" do
    context "of root node" do
      it "should be nil" do
        usa.parent.should == nil
      end
    end

    context "of child node" do
      it "should be parent" do
        illinois.parent.should == usa
      end
    end

    context "of leaf node" do
      it "should be parent" do
        chicago.parent.should == illinois
      end
    end
  end

  describe "ancestors" do
    context "of root node" do
      it "should be empty" do
        usa.ancestors.should be_empty
      end
    end

    context "of leaf node" do
      it "should be ancestors ordered by ascending distance" do
        chicago.ancestors.should == [illinois, usa]
      end
    end
  end

  describe "siblings" do
    context "of root node" do
      it "should be empty" do
        usa.siblings.should be_empty
      end
    end

    context "of child node" do
      it "should be other children of parent" do
        illinois.siblings.should include(indiana)
      end
    end
  end

  describe "children" do
    it "should be children" do
      usa.children.should include(illinois, indiana)
    end

    it "should be ordered" do
      alabama = Location.create! :parent => usa, :name => "Alabama"
      usa.children.should == [alabama, illinois, indiana]
    end

    context "of leaf" do
      it "should be empty" do
        chicago.children.should be_empty
      end
    end
  end

  describe "descendants" do
    it "should be all descendants" do
      usa.descendants.should include(illinois, indiana, chicago)
    end

    context "of leaf" do
      it "should be empty" do
        chicago.descendants.should be_empty
      end
    end
  end

  describe "root scope" do
    it "returns only root nodes" do
      Location.root.should include(usa, canada)
    end
  end

  describe "find_forest" do
    it "preloads all parents and children" do
      forest = Location.find_forest

      Location.where("purposely fail if any Location find happens here").scoping do
        forest.each do |tree|
          tree.descendants.each do |node|
            node.parent.should be
            node.children.should be_kind_of(ActiveRecord::Associations::CollectionProxy)
          end
        end
      end
    end

    it "works when scoped" do
      forest = Location.where(:name => "USA").find_forest
      forest.should include(usa)
    end

    it "preloads children in proper order" do
      alabama = Location.create! :parent => usa, :name => "Alabama"
      forest = Location.find_forest
      tree = forest.find { |l| l.id == usa.id }
      tree.children.should == [alabama, illinois, indiana]
    end

    context "with an infinite loop" do
      before do
        usa.update_attribute(:parent, chicago)
      end

      it "does not re-loop" do
        Location.find_forest
      end
    end
  end

  describe "find_tree" do
    it "finds by id" do
      tree = Location.find_tree usa.id
      tree.should == usa
    end

    it "finds multiple trees by id" do
      trees = Location.find_tree [indiana.id, illinois.id]
      trees.should include(indiana, illinois)
    end

    it "raises ActiveRecord::RecordNotFound when id is not found" do
      expect{Location.find_tree -1}.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "raises ActiveRecord::RecordNotFound when not all ids are not found" do
      expect{Location.find_tree [indiana.id, -1]}.to raise_error(ActiveRecord::RecordNotFound)
    end

  end

  describe "with_descendants" do
    context "unscoped" do
      it "returns all records" do
        Location.with_descendants.to_a.should =~ Location.all
      end
    end

    context "scoped" do
      it "returns a new scope that includes previously scoped records and their descendants" do
        Location.where(id: canada.id).with_descendants.to_a.should =~ [canada, british_columbia]
      end

      it "is not commutative" do
        Location.with_descendants.where(id: canada.id).to_a.should == [canada]
      end
    end
  end

  describe "self.acts_as_forest" do
    it 'can be used twice' do
      Location2 = Class.new(ActiveRecord::Base) do
        self.table_name = 'locations'
        acts_as_forest :order => "name"
      end
      Location2.find_forest
    end
  end
end
