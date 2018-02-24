module Aws
  module EC2
    class Instance
      METADATA_ENDPOINT = 'http://169.254.169.254/latest/meta-data'.freeze

      def self.local(*args)
        new(local_instance_id, args)
      end

      def self.local_instance_id
        Net::HTTP.get URI.parse("#{METADATA_ENDPOINT}/instance-id")
      end
    end
  end
end
