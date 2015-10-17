require 'spec_helper'

class Location < ActiveRecord::Base
  acts_as_forest :order => "name"
end

class BodyPart < ActiveRecord::Base
  acts_as_forest :foreign_key => "body_part_id"
end

Location.delete_all

describe "Edge::Forest" do
  let(:skeleton) { BodyPart.create! }
  let!(:usa) { Location.create! :name => "USA" }
  let!(:illinois) { Location.create! :parent => usa, :name => "Illinois" }
  let!(:chicago) { Location.create! :parent => illinois, :name => "Chicago" }
  let!(:indiana) { Location.create! :parent => usa, :name => "Indiana" }
  let!(:canada) { Location.create! :name => "Canada" }
  let!(:british_columbia) { Location.create! :parent => canada, :name => "British Columbia" }

  describe "root?" do
    context "of root node" do
      it "should be true" do
        expect(usa.root?).to eq true
      end
    end

    context "of model with custom foreign key" do
      it "should be true" do
        expect(skeleton.root?).to eq true
      end
    end

    context "of child node" do
      it "should be false" do
        expect(illinois.root?).to eq false
      end
    end

    context "of leaf node" do
      it "should be root node" do
        expect(chicago.root?).to eq false
      end
    end
  end

  describe "root" do
    context "of root node" do
      it "should be self" do
        expect(usa.root).to eq usa
      end
    end

    context "of child node" do
      it "should be root node" do
        expect(illinois.root).to eq usa
      end
    end

    context "of leaf node" do
      it "should be root node" do
        expect(chicago.root).to eq usa
      end
    end
  end

  describe "parent" do
    context "of root node" do
      it "should be nil" do
        expect(usa.parent).to eq nil
      end
    end

    context "of child node" do
      it "should be parent" do
        expect(illinois.parent).to eq usa
      end
    end

    context "of leaf node" do
      it "should be parent" do
        expect(chicago.parent).to eq illinois
      end
    end
  end

  describe "ancestors" do
    context "of root node" do
      it "should be empty" do
        expect(usa.ancestors).to be_empty
      end
    end

    context "of leaf node" do
      it "should be ancestors ordered by ascending distance" do
        expect(chicago.ancestors).to eq [illinois, usa]
      end
    end
  end

  describe "siblings" do
    context "of root node" do
      it "should be empty" do
        expect(usa.siblings).to be_empty
      end
    end

    context "of child node" do
      it "should be other children of parent" do
        expect(illinois.siblings).to include(indiana)
      end
    end
  end

  describe "children" do
    it "should be children" do
      expect(usa.children).to include(illinois, indiana)
    end

    it "should be ordered" do
      alabama = Location.create! :parent => usa, :name => "Alabama"
      expect(usa.children).to eq [alabama, illinois, indiana]
    end

    context "of leaf" do
      it "should be empty" do
        expect(chicago.children).to be_empty
      end
    end
  end

  describe "descendants" do
    it "should be all descendants" do
      expect(usa.descendants).to include(illinois, indiana, chicago)
    end

    context "of leaf" do
      it "should be empty" do
        expect(chicago.descendants).to be_empty
      end
    end
  end

  describe "root scope" do
    it "returns only root nodes" do
      expect(Location.root).to include(usa, canada)
    end
  end

  describe "find_forest" do
    it "preloads all parents and children" do
      forest = Location.find_forest

      Location.where("purposely fail if any Location find happens here").scoping do
        forest.each do |tree|
          tree.descendants.each do |node|
            expect(node.parent).to be
            expect(node.children).to be_kind_of(ActiveRecord::Associations::CollectionProxy)
          end
        end
      end
    end

    it "works when scoped" do
      forest = Location.where(:name => "USA").find_forest
      expect(forest).to include(usa)
    end

    it "preloads children in proper order" do
      alabama = Location.create! :parent => usa, :name => "Alabama"
      forest = Location.find_forest
      tree = forest.find { |l| l.id == usa.id }
      expect(tree.children).to eq [alabama, illinois, indiana]
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
      expect(tree).to eq usa
    end

    it "finds multiple trees by id" do
      trees = Location.find_tree [indiana.id, illinois.id]
      expect(trees).to include(indiana, illinois)
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
        rows = Location.with_descendants.to_a
        expect(rows).to match_array Location.all
      end
    end

    context "scoped" do
      it "returns a new scope that includes previously scoped records and their descendants" do
        rows = Location.where(id: canada.id).with_descendants.to_a
        expect(rows).to match_array [canada, british_columbia]
      end

      it "is not commutative" do
        rows = Location.with_descendants.where(id: canada.id).to_a
        expect(rows).to eq [canada]
      end
    end
  end

  describe "self.acts_as_forest" do
    it 'can be used twice' do
      class Location2 < ActiveRecord::Base
        self.table_name = 'locations'
        acts_as_forest :order => "name"
      end

      Location2.find_forest
    end
  end

  describe "dependent destroy" do
    it 'cascades destroys' do
      class Location3 < ActiveRecord::Base
        self.table_name = 'locations'
        acts_as_forest dependent: :destroy
      end

      Location3.find(usa.id).destroy

      expect(Location.exists?(usa.id)).to eq false
      expect(Location.exists?(illinois.id)).to eq false
      expect(Location.exists?(chicago.id)).to eq false
      expect(Location.exists?(indiana.id)).to eq false

      expect(Location.exists?(canada.id)).to eq true
      expect(Location.exists?(british_columbia.id)).to eq true
    end

  end
end
