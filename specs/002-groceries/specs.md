# Specifications for Groceries feature
This feature allows the agent to things like this:

What grocery lists do I have?
- tool call: get_grocery_lists()
- tool output:
    - "supermarket" (default)
    - "butcher"

What's on my grocery list?
- tool call: get_groceries(grocery_list_name)
- tool output:
    - 3, "bananas"
    - 4, "apples"

How many bananas are on my grocery list?
- tool call: get_grocery(grocery_list_name, item_name)
- tool output:
    - name: bananas
    - quantity: 3
    
How much milk is on my grocery list?
- tool call: get_grocery(grocery_list_name, item_name)
- tool output:
    - name: milk
    - quantity: "3 liters" (string)

Put peanut button on my grocery list.
- tool call: add_grocery(grocery_list_name, item_name, quantity)
- tool output:
    - name: peanut butter
    - quantity: 3 (apparently there were already 2 peanut butter on the list)

Clear the grocery list.
- tool call: clear_grocery_list(grocery_list_name)


# Non-functional requirements
- Create a function for fetching the default list UUID
