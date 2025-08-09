# frozen_string_literal: true
require "open3"
module Kiln
  module Services
    module ProcessRunner
      # Finds the repo under the current working directory or ../
      def self.repo_path(name)
        candidates = [
          File.join(Dir.pwd, name),
          File.expand_path(File.join(Dir.pwd, "..", name))
        ]
        candidates.find { |p| File.directory?(p) } || abort("Repo #{name} not found near #{Dir.pwd}")
      end

      def self.exec_in_repo(name, cmd, env: {}, stdin: nil)
        dir = repo_path(name)
        puts "[kiln] cd #{dir} && #{cmd.join(' ')}"
        Open3.popen3(env, *cmd, chdir: dir) do |i, o, e, t|
          i.write(stdin) if stdin
          i.close
          Thread.new { o.each_line { |l| STDOUT.print l } }
          Thread.new { e.each_line { |l| STDERR.print l } }
          status = t.value
          abort "[kiln] command failed (#{status.exitstatus})" unless status.success?
        end
      end
    end
  end
end
