-- ADR-0019: one store product per pack, and only one. The webhook resolves a
-- purchased product to a pack through this column alone, so a duplicate is a
-- purchase that grants two packs.
create unique index packs_store_product_id_key
  on public.packs (store_product_id)
  where store_product_id is not null;
