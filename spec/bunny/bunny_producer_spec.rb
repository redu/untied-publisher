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

        context "failing connection" do
          let(:bunny) do
            bunny = double('Bunny')
          end
          before do
            bunny.stub(:start).
              and_raise(::Bunny::TCPConnectionFailed.new(nil, "host", "port"))

            Producer.any_instance.stub(:connection).and_return(bunny)
          end
          let(:logger) { Publisher.config.logger }

          context ".new" do

            it "should log when connection is refused" do
              Producer.any_instance.stub(:connection).and_return(bunny)
              expect { Producer.new }.to_not raise_error
            end

            it "should log properly" do
              logger.should_receive(:info).with(/Channel was not setted up/)
              logger.should_receive(:info).with(/Producer intialized/)
              logger.should_receive(:info).with(/Can't connect to RabbitMQ/)

              Producer.new
            end
          end

          context "#publish" do
            it "should log properly" do
              subject = Producer.new
              bunny.stub(:status).and_return(:closed)
              logger.should_receive(:info).with(/Event not sent/)
              subject.safe_publish({})
            end
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
            Publisher.config.deliver_messages = false
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
