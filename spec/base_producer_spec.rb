require 'spec_helper'

module Untied
  module Publisher
    describe BaseProducer do
      context ".new" do
        it "should raise exception when there is no service_name" do
          Publisher.config.stub(:service_name).and_return(nil)
          expect {
            BaseProducer.new
          }.to raise_error(ArgumentError, /you should inform service_name/)
        end

        %w(routing_key service_name deliver_messages).each do |attr|
          it "should have #{attr} attr reader" do
            BaseProducer.new.should respond_to(attr)
          end
        end

        it "should log when message delivering is setted to false" do
          Publisher.config.logger.should_receive(:info).
            with(/Producer intialized with options/)
          Publisher.config.logger.should_receive(:info).
            with(/Channel was not/)
          BaseProducer.new(:deliver_messages => false)
        end
      end

    end
  end
end
