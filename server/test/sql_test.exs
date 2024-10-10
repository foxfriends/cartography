defmodule SqlTest do
  use ExUnit.Case
  doctest Sql

  import Sql

  test "no params" do
    assert Sql.to_query(~q"SELECT 1") == {"SELECT 1", []}
  end

  test "one param at start" do
    assert Sql.to_query(~q"#{:foxfriends} = 3") == {"$1 = 3", [:foxfriends]}
  end

  test "one param in middle" do
    assert Sql.to_query(~q"SELECT id FROM accounts WHERE username = #{:foxfriends} AND age > 20") ==
             {"SELECT id FROM accounts WHERE username = $1 AND age > 20", [:foxfriends]}
  end

  test "one param at end" do
    assert Sql.to_query(~q"SELECT id FROM accounts WHERE username = #{:foxfriends}") ==
             {"SELECT id FROM accounts WHERE username = $1", [:foxfriends]}
  end

  test "two param" do
    assert Sql.to_query(
             ~q"SELECT id FROM accounts WHERE firstname = #{:cameron} AND lastname = #{:eldridge}"
           ) ==
             {"SELECT id FROM accounts WHERE firstname = $1 AND lastname = $2",
              [:cameron, :eldridge]}
  end

  test "raw does not become param" do
    raw = Sql.raw("'foxfriends'")

    assert Sql.to_query(~q"SELECT id FROM accounts WHERE username = #{raw}") ==
             {"SELECT id FROM accounts WHERE username = 'foxfriends'", []}
  end

  test "nested sql interpolates together" do
    first = ~q"firstname = #{:cameron}"
    last = ~q"lastname = #{:eldridge}"
    condition = ~q"#{first} AND #{last}"

    assert Sql.to_query(~q"SELECT id FROM accounts WHERE #{condition}") ==
             {"SELECT id FROM accounts WHERE firstname = $1 AND lastname = $2",
              [:cameron, :eldridge]}
  end
end
