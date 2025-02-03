import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensures user can start and end meditation session",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall(
        "zen-sync",
        "start-session",
        [types.utf8("mindfulness")],
        wallet_1.address
      )
    ]);
    assertEquals(block.receipts[0].result.expectOk(), true);
    
    chain.mineEmptyBlockUntil(600); // 10 minutes later
    
    block = chain.mineBlock([
      Tx.contractCall(
        "zen-sync", 
        "end-session",
        [],
        wallet_1.address
      )
    ]);
    assertEquals(block.receipts[0].result.expectOk(), true);
  },
});
