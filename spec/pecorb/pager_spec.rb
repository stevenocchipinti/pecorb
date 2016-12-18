require_relative "../../lib/pecorb/pager"

RSpec.describe Pecorb::Pager do
  let(:items) { %w[one two three four five] }
  let(:viewport) { 4 }
  let(:pager) { described_class.new(items, viewport) }

  describe "rolling window behaviour" do
    context "when reaching the end of the visible items" do
      it "wraps around to the top" do
        expect(pager.selected_item).to eq("one")
        pager.down
        expect(pager.selected_item).to eq("two")
        pager.down
        expect(pager.selected_item).to eq("three")
        pager.down
        expect(pager.selected_item).to eq("four")
        pager.down
        expect(pager.selected_item).to eq("five")
        pager.down
        expect(pager.selected_item).to eq("one")
      end

      it "scrolls the whole items down with the cursor" do
        expect(pager.items_in_viewport).to eq(%w[one two three four])
        pager.down
        expect(pager.items_in_viewport).to eq(%w[one two three four])
        pager.down
        expect(pager.items_in_viewport).to eq(%w[one two three four])
        pager.down
        expect(pager.items_in_viewport).to eq(%w[one two three four])
        pager.down
        expect(pager.items_in_viewport).to eq(%w[two three four five])
        pager.down
        expect(pager.items_in_viewport).to eq(%w[one two three four])
      end
    end

    context "when reaching the start of the visible items" do
      it "wraps around to the end" do
        expect(pager.selected_item).to eq("one")
        pager.up
        expect(pager.selected_item).to eq("five")
        pager.up
        expect(pager.selected_item).to eq("four")
        pager.up
        expect(pager.selected_item).to eq("three")
        pager.up
        expect(pager.selected_item).to eq("two")
        pager.up
        expect(pager.selected_item).to eq("one")
      end

      it "scrolls the whole items up with the cursor" do
        expect(pager.items_in_viewport).to eq(%w[one two three four])
        pager.up
        expect(pager.items_in_viewport).to eq(%w[two three four five])
        pager.up
        expect(pager.items_in_viewport).to eq(%w[two three four five])
        pager.up
        expect(pager.items_in_viewport).to eq(%w[two three four five])
        pager.up
        expect(pager.items_in_viewport).to eq(%w[two three four five])
        pager.up
        expect(pager.items_in_viewport).to eq(%w[one two three four])
      end
    end

    context "when the items are replaced" do
      let(:new_items) { %w[one two four] }

      context "when the cursor is at the bottom" do
        it "leaves the cursor at the bottom of the new items of items" do
          expect(pager.selected_item).to eq("one")
          expect(pager.items_in_viewport).to eq(%w[one two three four])
          4.times { pager.down }
          expect(pager.selected_item).to eq("five")
          expect(pager.items_in_viewport).to eq(%w[two three four five])
          pager.items = new_items

          expect(pager.selected_item).to eq("four")
          expect(pager.items_in_viewport).to eq(%w[one two four])
        end
      end

      context "when the cursor is at the top" do
        it "leaves the cursor at the top of the new items of items" do
          expect(pager.selected_item).to eq("one")
          expect(pager.items_in_viewport).to eq(%w[one two three four])
          pager.items = new_items
          expect(pager.selected_item).to eq("one")
          expect(pager.items_in_viewport).to eq(%w[one two four])
        end
      end
    end
  end


  describe "fuzzy filtering behaviour" do
    context "when given a character" do
      it "returns the items that contain the character regardless of case" do
        expect(pager.items_in_viewport).to eq(%w[one two three four])
        pager.filter! "F"
        expect(pager.items_in_viewport).to eq(%w[four five])
      end
    end

    context "when given two characters" do
      it "returns the items that contain both characters in order" do
        expect(pager.items_in_viewport).to eq(%w[one two three four])
        pager.filter! "FR"
        expect(pager.items_in_viewport).to eq(%w[four])
      end
    end

    context "when the filter is set to empty string" do
      it "returns the original items unfiltered" do
        pager.filter! "FR"
        expect(pager.items_in_viewport).to eq(%w[four])
        pager.filter! ""
        expect(pager.items_in_viewport).to eq(%w[one two three four])
      end
    end

    context "when the filter is set to nil" do
      it "returns the original items unfiltered" do
        pager.filter! "FR"
        expect(pager.items_in_viewport).to eq(%w[four])
        pager.filter! nil
        expect(pager.items_in_viewport).to eq(%w[one two three four])
      end
    end
  end
end
