require 'aws-sdk'
require 'net/http'
require 'logger'

module Aws
  module Utils
    class UpdatePublicIP

      EC2_METADATA_ENDPOINT = 'http://169.254.169.254/latest/meta-data'

      def initialize
        @logger     = Logger.new STDOUT
        @instance   = Aws::EC2::Instance.new get_instance_id
        @route53    = Aws::Route53::Client.new
        @current_ip = get_ip
      end

      def get_ip
        @logger.debug 'Obtaining the current instance IP from AWS API'
        ip = @instance.public_ip_address
        @logger.debug "Found the public IP of the current instance to be #{ip}"
        ip
      end

      def get_instance_id
        @logger.debug "Obtaining the current instance ID from #{EC2_METADATA_ENDPOINT}"
        instance_id = Net::HTTP.get URI.parse "#{EC2_METADATA_ENDPOINT}/instance-id"
        @logger.debug "Instance ID found to be #{instance_id}"
        instance_id
      end

      def get_zone
        zone = nil
        fqdn = @target_rrset.dup
        @logger.debug "Trying to establish which Route53 zone the FQDN: #{fqdn} belongs to"
        fqdn.split('.').each do |level|
          # Try and find a zone with zone
          @logger.debug "Trying #{fqdn}"
          resp = @route53.list_hosted_zones
          if !resp.hosted_zones.empty?
            resp.hosted_zones.each do |hosted_zone|
              if hosted_zone.name == "#{fqdn}."
                @logger.debug 'Found the zone'
                zone = resp.hosted_zones[0].id.gsub(/\/hostedzone\//,'')
                break
              end
            end
            unless zone
              @logger.debug 'Failed to find a zone so chop off a subdomain and try again'
              fqdn = fqdn.gsub("#{level}.",'')
            end
          else
            raise Exception, 'No zones found in Route53'
          end
          break if zone
        end
        raise Exception, 'Zone not found the requested FQDN' unless zone
        @logger.debug "Zone found to be #{zone}"
        zone
      end

      def update_rrset
        @logger.debug "Creating the rrset with name: '#{@target_rrset}' and value: '#{@current_ip}' in the zone with ID: '#{@target_zone_id}'"
        @route53.change_resource_record_sets({
          hosted_zone_id: @target_zone_id,
            change_batch: {
             changes: [
                        {
                          action: 'UPSERT',
                          resource_record_set: {
                            name: @target_rrset,
                            type: 'A',
                            ttl: 10,
                            resource_records: [
                                    {
                                      value: @current_ip
                                    },
                                  ],
                          }
                        }
                      ]
            }
          })
        @logger.debug 'Created the rrset'
      end

      def run!(fqdn)
        @target_rrset   = fqdn
        @target_zone_id = get_zone
        update_rrset
      end

    end
  end
end
