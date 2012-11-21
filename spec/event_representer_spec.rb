require 'spec_helper'

module Untied
  describe Event do
    before(:all) do
      module PostRepresenter
        include Representable::JSON

        property :title
      end
    end
    let(:post) { Post.create(:title => "DIY") }

    context "#to_json" do
      it "should serialize according with EventRepresenter" do
        event = Event.new(:name => "foo", :payload => {}, :origin => :bar)
        JSON.parse(event.to_json).to_a.sort.should ==
          { "event" =>
            { "name" => "foo", "origin" => "bar", "payload" => {  } } }.to_a.sort
      end

      it "should represent payload" do
        event = Event.new(:name => "foo", :payload => post, :origin => :bar,
                         :payload_representer => PostRepresenter)

        JSON.parse(event.to_json).to_a.sort.should ==
          { "event" =>
            { "name" => "foo", "origin" => "bar",
              "payload" => { "title" => "DIY" } } }.to_a.sort
      end

      it "should fallback to default to_json when there is no representer" do
        person = User.create(:name => "Guila")
        event = Event.new(:name => "foo", :payload => person, :origin => :bar)

        JSON.parse(event.to_json).to_a.sort.should ==
          { "event" =>
            { "name" => "foo", "origin" => "bar",
              "payload" => JSON.parse(person.to_json) } }.to_a.sort
      end
    end
  end
end
