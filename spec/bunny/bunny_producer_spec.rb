require 'spec_helper'

module Untied
  module Publisher
    module Bunny
      describe Producer do
        context ".new" do
          it "call super" do
            Producer.should_receive(:new)
            Producer.new
          end
        end

        context "#publish" do
          let(:connection) { ::Bunny.new }
          let(:channel) { connection.create_channel }
          let(:exchange) { channel.topic('untied', :auto_delete => true) }
          let(:event) do
            Event.new(:name => "create", :payload => { :foo => 'bar' },
                      :origin => :core)
          end
          before do
            connection.start
            Publisher.config.deliver_messages = true
          end
          after do
            connection.close
          end

          it "should route the message correctly" do
            queue = channel.queue("", :exclusive => true).
              bind(exchange, :routing_key => "untied.core")
            subject.publish(event)

            sleep(1)

            queue.message_count.should == 1
            channel.close
          end
        end
      end
    end
  end
end
