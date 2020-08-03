# lora-georgiou-raza
Script for LoRa's stochastic geometry scheme and ring model first introduced in [1]. The script implement the capture (1-collision) probability Q_1 considering the sum of co-interference, as in [2, Sec. B-1]. The result equation used for the capture probability is an adaptation of [3, Eq. 7], changing the integration limits of (0,R) to (r1,r2), resulting on [4, Eq. 6].

## Important Notes

* For the simulation results, use samples = 10^4 to get faster results and samples = 10^5 for better precision.
* Vector E_db and R_ring must present the same length, where each position refers to a different ring and SF. If you want to include or remove some SF/rings, you can just resize them, as long as they remain with the same length.
* If you suffer from a long simulation time, you can change the 'for' in line 66 to a 'parfor'. The gain will be proportional to the number of threads your CPU presents/are available.

# References

* [1] O. Georgiou and U. Raza, "Low Power Wide Area Network Analysis: Can LoRa Scale?," in IEEE Wireless Communications Letters, vol. 6, no. 2, pp. 162-165, April 2017, doi: 10.1109/LWC.2016.2647247. Open Pre-print at: https://arxiv.org/abs/1610.04793
* [2] A. Mahmood, E. Sisinni, L. Guntupalli, R. Rondón, S. A. Hassan and M. Gidlund, "Scalability Analysis of a LoRa Network Under Imperfect Orthogonality," in IEEE Transactions on Industrial Informatics, vol. 15, no. 3, pp. 1425-1436, March 2019, doi: 10.1109/TII.2018.2864681. Open Pre-print at: https://arxiv.org/abs/1808.01761
* [3] J. M. S. Sant’Ana, A. Hoeller, R. D. Souza, S. Montejo-Sánchez, H. Alves and M. d. Noronha-Neto, "Hybrid Coded Replication in LoRa Networks," in IEEE Transactions on Industrial Informatics, vol. 16, no. 8, pp. 5577-5585, Aug. 2020, doi: 10.1109/TII.2020.2966120. Open Pre-print at: https://arxiv.org/abs/2001.08168
* [4] J. M. S. Sant’Ana, A. Hoeller, R. D. Souza, H. Alves and S. Montejo-Sánchez, "LORA Performance Analysis with Superposed Signal Decoding," in IEEE Wireless Communications Letters, doi: 10.1109/LWC.2020.3006588.
