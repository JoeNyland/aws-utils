module Aws
  module Utils
    class Error < StandardError
      class MissingArgument < Error; end
      class SecurityGroupNotFound < Error; end
    end
  end
end
