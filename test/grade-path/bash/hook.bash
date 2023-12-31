# Setup scripts run
question 1 "root grade-seth.bash sourced" test "$ROOT_SETUP_SCRIPT_SOURCED_BASH" = yes
question 1 "branch grade-seth.bash sourced" test "$BRANCH_SETUP_SCRIPT_SOURCED_BASH" = yes

# Negatives are accounted for properly
question 1 "question correctly registers failure (THIS QUESTION SHOULD FAIL)" false
extra_credit 1 "extra_credit works in hook script" true # to make up for the missed question above
extra_credit 1 "extra_credit correctly registers failure (THIS QUESTION SHOULD FAIL)" false