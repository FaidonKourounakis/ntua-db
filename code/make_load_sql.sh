#!/bin/bash
echo "Writing fake data to ../sql/load.sql ..."
python ./print_fake_data.py > ../sql/load.sql
cat ./adjust_data_for_Q14.sql >> ../sql/load.sql
echo "Done!"
