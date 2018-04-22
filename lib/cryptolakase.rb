require "cryptolakase/version"
require "json"
require "digest"

module Cryptolakase
  class Blockchain
    attr_reader :chain

    def initialize()
      @chain = []
      @current_transactions = []

      #generate genesis block
      new_block(100,1)
    end

    def new_block(proof, previous_hash)
      block = {
          :index => @chain.count + 1,
          :timestamp => Time.now.to_i,
          :transactions => @current_transactions,
          :proof => proof,
          :previous_hash => previous_hash ||= self.hash(@chain[-1])
      }

      @current_transactions = []

      @chain.push(block)

      block
    end

    def new_transaction(sender, recipient, amount)
      @current_transactions.push({
        :sender => sender,
        :recipient => recipient,
        :amount => amount
      })

      @chain.index(last_block)
    end

    def last_block
      @chain[-1]
    end

    def proof_of_work(last_proof)
      # calculates a number that concatenated to the last_proof will return a hash with 4 leading zeros
      # gdfsdfsd..0000

      proof = 0
      while !Blockchain.valid_proof(last_proof, proof) do
        proof += 1
      end

      proof
    end

    def hash(block)
      Blockchain.hash(block)
    end

    def self.hash(block)
      # return SHA256 for the given block
      block_string = block.to_json

      Digest::SHA256.hexdigest(block_string)
    end

    def self.valid_proof(last_proof,proof)
      # return true if the resulting hash has 4 leading zeros
      guess = "#{last_proof}#{proof}"
      guess_hash = Digest::SHA256.hexdigest(guess)

      guess_hash.to_s[-4..-1] == '0000'
    end
  end
end
