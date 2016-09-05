require 'aws/error/multiple_security_group_match_error'
require 'aws-sdk'
require 'open-uri'
require 'ipaddr'
require 'core_ext'

module Aws
  module Utils
    module EC2
      module UpdatePublicIP

        # Update the IP address to the current IP address of the local machine
        def self.update_public_ip_in_security_group(group_name)

          @client = Aws::EC2::Client.new
          @security_group = get_sg(group_name)
          @current_ip_cidr = get_current_ip.to_cidr_s

          begin
            @client.authorize_security_group_ingress(
              group_id: @security_group.group_id,
              ip_protocol: '-1',
              cidr_ip: @current_ip_cidr
            )
          rescue Aws::EC2::Errors::InvalidPermissionDuplicate
            # If this type of exception is raised, we don't need to update the Security Group
            puts "The current IP address (#{@current_ip_cidr}) is already present in the Security Group '#{@security_group.group_id}: #{@security_group.group_name}'"
          else
            puts "Successfully added the IP: #{@current_ip_cidr} to the Security Group '#{@security_group.group_id}: #{@security_group.group_name}'"
          ensure
            # Clean up and non-duplicate rules
            clean_rules(@security_group, @current_ip_cidr)
          end

        end

        private

        # Returns or creates and returns an EC2 security group with a given name
        def self.get_sg(group_name)

          # Check we were given a non-empty group name
          raise ArgumentError, 'Empty group name' if group_name.empty? or !group_name.instance_of? String

          # Try and find the group
          begin
            begin
              groups = @client.describe_security_groups(group_names: [group_name])[:security_groups]
            rescue Aws::EC2::Errors::InvalidParameterValue => e
              if e.message.match /You may not reference Amazon VPC security groups by name\. Please use the corresponding id for this operation\./
                groups = @client.describe_security_groups(
                  filters: [
                             name:   'group-name',
                             values: [group_name]
                           ]
                )[:security_groups]
              else
                raise e
              end
            end
          rescue Aws::EC2::Errors::InvalidGroupNotFound => e
            # Group not found, so create one and return the new SG
            group_id = create_sg(group_name).group_id
            return @client.describe_security_groups(group_ids: [group_id])[:security_groups].first
          end

          # Make sure that we've found just one Security Group
          if groups.length > 1
            # We can't return an ID if there's several groups returned
            raise Aws::MultipleSGMatchError, "More than one Security Group matches and therefore can't find a specific group to target"
          else
              # Return the SG
              groups.first
          end

        end

        # Creates a Security Group in VPC/EC2
        def self.create_sg(group_name)

          sg = @client.create_security_group(
            group_name: group_name,
            description: group_name.capitalize,
            vpc_id: get_vpc.vpc_id
          )

          # Remove the default egress rule
          @client.revoke_security_group_egress(
            group_id: sg.group_id,
            ip_permissions: [ ip_ranges: [ cidr_ip: '0.0.0.0/0' ], ip_protocol: '-1' ]
          )

          # Return the SG
          sg

        end

        def self.get_vpc
          @client.describe_vpcs.vpcs.first
        end

        # Gets the current public IP of the local machine
        def self.get_current_ip
          # Get current IP address and strip newline characters
          IPAddr.new(open('http://icanhazip.com').read.strip)
        end

        # Remove all other rules in this group if they're not for the current IP address
        def self.clean_rules(security_group,cidr_ip)
          perms = security_group.ip_permissions
          perms.each do |perm|
            protocol = perm.ip_protocol
            ip = perm.ip_ranges.first.cidr_ip
            unless protocol == '-1' && ip == cidr_ip
              # This rule needs removing
              puts "Cleaning rule for old IP: #{ip}"
              @client.revoke_security_group_ingress(
                group_id: security_group.group_id,
                ip_permissions: [
                                   ip_ranges:   [ cidr_ip: ip ],
                                   ip_protocol: protocol,
                                   from_port:   perm.from_port,
                                   to_port:     perm.to_port
                                 ]
              )
            end
          end
        end

      end
    end
  end
end
