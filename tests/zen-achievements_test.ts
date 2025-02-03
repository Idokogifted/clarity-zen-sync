import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensures achievement NFTs can be minted",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall(
        "zen-achievements",
        "mint-achievement",
        [types.uint(10), types.utf8("master-meditator")],
        wallet_1.address
      )
    ]);
    assertEquals(block.receipts[0].result.expectOk(), types.uint(1));
  },
});
