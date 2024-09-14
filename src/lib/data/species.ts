export const species = {
  cat: {
    type: "cat",
    name: "Cat",
    needs: [{ type: "resource", resource: "bread", quantity: 1 }],
  },
  rabbit: {
    type: "rabbit",
    name: "Rabbit",
    needs: [{ type: "resource", resource: "salad", quantity: 1 }],
  },
};
