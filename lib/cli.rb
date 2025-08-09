# frozen_string_literal: true
require "json"
require "optparse"
require_relative "services/process_runner"
require_relative "clients/al_uls_client"

module Kiln
  class CLI
    def self.start(argv)
      cmd = argv.shift
      case cmd
      when "optimize"    then Optimize.new.run(argv)
      when "limps"       then LIMPS.new.run(argv)
      when "chaos-rag"   then ChaosRAG.new.run(argv)
      when "limp"        then LiMp.new.run(argv)
      when "eopiez"      then Eopiez.new.run(argv)
      when "enjoypy"     then EnjoyPy.new.run(argv)
      else
        puts <<~USAGE
          kiln <command> [options]

          Commands:
            optimize     Run al-ULS optimization/stability/entropy over HTTP
            limps        Run unified LIMPS workflow (Python)
            chaos-rag    Invoke TEmp-oral_vectraxice chaos RAG / training
            limp         Start/stop LiMp (TypeScript) service
            eopiez       Run Julia snippet from Eopiez with JSON IO
            enjoypy      Execute helper utilities from enjoypy

          Try `kiln <command> --help`
        USAGE
        exit 1
      end
    end

    class Optimize
      def run(argv)
        opts = {
          host: "127.0.0.1", port: 8080, method: "auto",
          target_entropy: nil, json: nil
        }
        OptionParser.new do |o|
          o.banner = "Usage: kiln optimize --json matrix.json [--method auto|kfp|stability|entropy|rank|sparsity] [--host 127.0.0.1 --port 8080] [--target-entropy 0.7]"
          o.on("--json PATH", "JSON with {\"matrix\":[[...],[...]]}") { |v| opts[:json] = v }
          o.on("--method M")   { |v| opts[:method] = v }
          o.on("--host H")     { |v| opts[:host]   = v }
          o.on("--port P", Integer) { |v| opts[:port] = v }
          o.on("--target-entropy F", Float) { |v| opts[:target_entropy] = v }
        end.parse!(argv)

        abort "Provide --json file" unless opts[:json] && File.exist?(opts[:json])
        payload = JSON.parse(File.read(opts[:json]))
        client  = Clients::AlULSClient.new(host: opts[:host], port: opts[:port])
        res     = client.optimize(matrix: payload["matrix"], method: opts[:method], target_entropy: opts[:target_entropy])
        puts JSON.pretty_generate(res)
      end
    end

    class LIMPS
      def run(argv)
        action = argv.shift || "run"
        env = { "PYTHONUNBUFFERED" => "1" }
        case action
        when "run"
          # Example: python main.py --mode workflow --gpu (from the repo README/structure)
          # You can adjust paths as needed.
          cmd = ["python", "main.py", "--mode", "workflow", "--gpu"]
          Services::ProcessRunner.exec_in_repo("9xdSq-LIMPS-FemTO-R1C", cmd, env: env)
        when "health"
          # Add a curl or file-based health check here if the workflow exposes one
          puts "LIMPS health: (stub) ok"
        else
          abort "Unknown limps action"
        end
      end
    end

    class ChaosRAG
      def run(argv)
        sub = argv.shift
        case sub
        when "train"
          # e.g., python sweet integrated_training_system.py --dataset data/...
          cmd = ["python", "sweet integrated_training_system.py"]
          Services::ProcessRunner.exec_in_repo("TEmp-oral_vectraxice", cmd)
        when "route"
          # Example: call ta_uls_llm.py to route text via chaos RAG logic
          input = ARGF.read
          tmp = File.join(Dir.pwd, ".kiln_tmp_input.txt")
          File.write(tmp, input)
          cmd = ["python", "ta_uls_llm.py", "--in", tmp]
          Services::ProcessRunner.exec_in_repo("TEmp-oral_vectraxice", cmd)
        else
          puts "Usage: kiln chaos-rag [train|route] < file.txt"
        end
      end
    end

    class LiMp
      def run(argv)
        action = argv.shift || "start"
        case action
        when "start"
          # Start dev server (adjust npm script name if different)
          Services::ProcessRunner.exec_in_repo("LiMp", ["npm", "run", "dev"])
        when "build"
          Services::ProcessRunner.exec_in_repo("LiMp", ["npm", "run", "build"])
        else
          abort "Unknown limp action"
        end
      end
    end

    class Eopiez
      def run(argv)
        # Pipe JSON to Julia; expect JSON back on stdout
        json_in = ARGF.read
        file = "eval.jl"
        code = <<~JL
          using JSON
          s = read(stdin, String)
          data = JSON.parse(s)
          # TODO: call your real functions; here we just echo structure
          println(JSON.json(Dict("received"=>data, "ok"=>true)))
        JL
        Services::ProcessRunner.exec_in_repo("Eopiez", ["julia", "--project=.", "-e", code], stdin: json_in)
      end
    end

    class EnjoyPy
      def run(argv)
        # wrap a helper script in enjoypy, e.g., enjoy.py --mode something
        cmd = ["python", "enjoy.py"] + argv
        Services::ProcessRunner.exec_in_repo("enjoypy", cmd)
      end
    end
  end
end
