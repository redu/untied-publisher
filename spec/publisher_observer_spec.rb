# -*- encoding : utf-8 -*-
require 'spec_helper'

module Untied
  module Publisher
    describe Observer do
      before do
        class ::FooDoorkeeper
          include Untied::Publisher::Doorkeeper
        end
        Untied::Publisher.config.doorkeeper = ::FooDoorkeeper
        module UserRepresenter
        end
      end
      let(:doorkeeper) { ::FooDoorkeeper.new }

      context ".instance" do
        it "should raise a friendly error when no doorkeeper is defined" do
          Untied::Publisher.config.doorkeeper = nil
          klass = Class.new(Observer)
          expect {
            klass.instance
          }.to raise_error(/should define a class which includes/)
        end
      end

      context "ActiveRecord::Callbacks" do
        let(:user) { User.create(:name => "Guila") }

        it "should proxy #produce_event" do
          Observer.instance.should_receive(:produce_event)
          Observer.instance.send(:after_create, user)
        end

        context "passing :represent_with" do
          it "should call user.extend(UserRepresenter)" do
            user.should_receive(:extend).with(UserRepresenter)
            Observer.instance.
              send(:after_create, user, :represent_with => UserRepresenter)
          end
        end
      end

      context "#producer" do
        it "should return the Producer" do
          Observer.instance.should respond_to(:producer)
        end
      end

      context "when callbacks are fired" do
        let(:producer) { double('Untied::Producer') }

        ActiveRecord::Callbacks::CALLBACKS.each do |callback|
          it "should publish the event on #{callback}" do
            Observer.instance.stub(:producer).and_return(producer)
            producer.should_receive(:publish).with(an_instance_of(Event))
            Observer.instance.send(callback, double('User'))
          end
        end
      end
    end
  end
end
