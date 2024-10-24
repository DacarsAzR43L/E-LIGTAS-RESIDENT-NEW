-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 24, 2024 at 06:51 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `capst_project_new`
--

-- --------------------------------------------------------

--
-- Table structure for table `emergency_hotlines`
--

CREATE TABLE `emergency_hotlines` (
  `hotlines_id` int(100) NOT NULL,
  `sector_from` varchar(100) NOT NULL,
  `hotlines_number` varchar(100) NOT NULL,
  `sector_id` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `emergency_hotlines`
--

INSERT INTO `emergency_hotlines` (`hotlines_id`, `sector_from`, `hotlines_number`, `sector_id`) VALUES
(1, 'Pulong Buhangin', '639993161582', ''),
(2, 'Patag', '63209248815', ''),
(3, 'Caypombo', '639416567581', ''),
(4, 'Catmon', '639416567581', ''),
(5, 'Poblacion', '639452641487', ''),
(6, 'Santa Clara', '639245618572', ''),
(7, 'Balasing', '6394582536254', ''),
(8, 'Bulac', '639487562510', ''),
(9, 'San Vicente', '63945123585', ''),
(10, 'Tumana', '639844565128', ''),
(11, 'MDRRMO', '63452586', ''),
(12, 'BFP', '870000', '');

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `files`
--

CREATE TABLE `files` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `path` varchar(255) NOT NULL,
  `mime_type` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `guidelines`
--

CREATE TABLE `guidelines` (
  `guidelines_id` bigint(20) UNSIGNED NOT NULL,
  `guidelines_name` varchar(255) NOT NULL,
  `thumbnail` varchar(255) NOT NULL,
  `disaster_type` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `guidelines`
--

INSERT INTO `guidelines` (`guidelines_id`, `guidelines_name`, `thumbnail`, `disaster_type`, `created_at`, `updated_at`) VALUES
(1, 'Earthquake', '../e-ligtas-sector/upload/image_1705920244.jpg', 'Natural Disaster', '2024-01-22 23:37:05', '2024-01-26 00:05:01'),
(2, 'Crime', '../e-ligtas-sector/upload/image_1702802011.jpg', 'Man Made Disaster', '2024-01-24 21:00:31', '2024-01-24 21:00:31');

-- --------------------------------------------------------

--
-- Table structure for table `guidelines_after`
--

CREATE TABLE `guidelines_after` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `guidelines_id` bigint(20) UNSIGNED NOT NULL,
  `headings` varchar(255) NOT NULL,
  `image` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `guidelines_after`
--

INSERT INTO `guidelines_after` (`id`, `guidelines_id`, `headings`, `image`, `description`, `created_at`, `updated_at`) VALUES
(5, 1, 'This is what you need to do after the Earthquake', '../e-ligtas-sector/upload/image_1706011351.jpg', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum', '2024-01-22 23:37:05', '2024-01-24 20:50:21'),
(8, 2, 'asdasd', '../e-ligtas-sector/upload/image_1706016141.jpg', 'sdsdsdsdsdsdsdsdsd\r\nsdsdsdsdsdsdsdsd\r\nsdsdsdsdsdsdsds\r\nsdsdsdsds\r\nsd', '2024-01-24 21:00:31', '2024-01-24 21:00:31');

-- --------------------------------------------------------

--
-- Table structure for table `guidelines_before`
--

CREATE TABLE `guidelines_before` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `guidelines_id` bigint(20) UNSIGNED NOT NULL,
  `headings` varchar(255) NOT NULL,
  `image` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `guidelines_before`
--

INSERT INTO `guidelines_before` (`id`, `guidelines_id`, `headings`, `image`, `description`, `created_at`, `updated_at`) VALUES
(5, 1, 'asdasd', '../e-ligtas-sector/upload/image_1706258396.jpg', 'José Rizal was born on June 19, 1861 to Francisco Rizal Mercado y Alejandro and Teodora Alonso Realonda y Quintos in the town of Calamba in Laguna province. He had nine sisters and one brother. is parents were leaseholders of a hacienda and an \n\naccompanying rice farm held by the Dominicans. Both their families had adopted the additional surnames of Rizal and Realonda in \n1849 after Governor General Narciso Clavería y Zaldúa decreed the adoption of Spanish surnames among the Filipinos for census \n\npurposes (though they already had Spanish names).^^^^$%$%$%DFDF', '2024-01-22 23:37:05', '2024-01-24 20:49:30'),
(8, 2, 'asdasd', '../e-ligtas-sector/upload/image_1706259764.jpg', 'sdsdsdsdsdsdsdsdsd\nsdsdsdsdsdsdsdsd\nsdsdsdsdsdsdsds\nsdsdsdsds\nsd', '2024-01-24 21:00:31', '2024-01-24 21:00:31');

-- --------------------------------------------------------

--
-- Table structure for table `guidelines_during`
--

CREATE TABLE `guidelines_during` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `guidelines_id` bigint(20) UNSIGNED NOT NULL,
  `headings` varchar(255) NOT NULL,
  `image` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `guidelines_during`
--

INSERT INTO `guidelines_during` (`id`, `guidelines_id`, `headings`, `image`, `description`, `created_at`, `updated_at`) VALUES
(5, 1, 'asdasdasd', '../e-ligtas-sector/upload/image_1706016183.jpg', 'Covering your face is an important practice to help prevent the spread of germs and protect yourself and others. It is especiallcrucial during times of illness or when in close proximity to others, such as in crowded public spaces. Wearing a face mask, a cloth covering, or even using a scarf or bandana to\r\n\r\n\r\n cover your nose and mouth can help to reduce the transmission of respiratory droplets that may contain viruses or bacteria. This simple act can go a long way in keeping yourself and those around you safe and healthy. Remember to properly wash or dispose of your face coverings after each use to maintain cleanliness and effectiveness. \r\n\r\n\r\nsds\r\nsd\r\nsds\r\nds\r\nds\r\nds\r\nds\r\nds\r\ndsd', '2024-01-22 23:37:05', '2024-01-24 20:34:37'),
(8, 2, 'asdasd', '../e-ligtas-sector/upload/image_1706016183.jpg', 'awit', '2024-01-24 21:00:31', '2024-01-24 21:00:31');

-- --------------------------------------------------------

--
-- Table structure for table `login`
--

CREATE TABLE `login` (
  `uid` varchar(55) NOT NULL,
  `email` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `login`
--

INSERT INTO `login` (`uid`, `email`) VALUES
('PPCGesdtogNbBCNp3IkTKuIikA63', 'raphaeldacara62@gmail.com'),
('uESfipEYxrf3sgppz5LZFoxEtgr2', 'rdacara.ccci@gmail.com');

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '2014_10_12_000000_create_users_table', 1),
(2, '2014_10_12_100000_create_password_reset_tokens_table', 1),
(3, '2019_08_19_000000_create_failed_jobs_table', 1),
(4, '2019_12_14_000001_create_personal_access_tokens_table', 1),
(5, '2023_11_16_195233_create_files_table', 1),
(6, '2023_12_16_080440_create_reports_table', 1),
(7, '2024_01_06_031350_create_table_emergency_hotlines', 1),
(8, '2024_01_21_150307_create_guidelines_table', 2),
(9, '2024_01_21_150343_create_guidelines_after_table', 2),
(10, '2024_01_21_150356_create_guidelines_before_table', 2),
(11, '2024_01_21_150405_create_guidelines_during_table', 2),
(12, '2024_01_26_041654_create_settings_table', 3);

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reports`
--

CREATE TABLE `reports` (
  `report_id` int(255) NOT NULL,
  `dateandTime` datetime(6) NOT NULL,
  `uid` varchar(100) NOT NULL,
  `emergency_type` varchar(55) NOT NULL,
  `resident_name` varchar(55) NOT NULL,
  `locationName` varchar(55) NOT NULL,
  `locationLink` varchar(100) NOT NULL,
  `phoneNumber` varchar(55) NOT NULL,
  `message` varchar(255) NOT NULL,
  `imageEvidence` varchar(1000) NOT NULL,
  `status` varchar(255) NOT NULL,
  `sectorName` varchar(500) NOT NULL,
  `responder_name` varchar(55) NOT NULL,
  `userfrom` varchar(255) NOT NULL,
  `residentProfile` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `resident_credentials`
--

CREATE TABLE `resident_credentials` (
  `uid` varchar(55) NOT NULL,
  `email` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `resident_credentials`
--

INSERT INTO `resident_credentials` (`uid`, `email`) VALUES
('dPHSTyCXMlcN16KPethTpxtKyrm1', 'raphaeldacara62@gmail.com'),
('qP8i7htsUMOVGHxYMQYUJWdJi1h1', 'makimasarap69@gmail.com'),
('zryBJzIfUnUmrvBxdyINfxn5PRy1', 'awitsayo423@gmail.com');

-- --------------------------------------------------------

--
-- Table structure for table `resident_profile`
--

CREATE TABLE `resident_profile` (
  `uid` varchar(55) NOT NULL,
  `name` varchar(55) NOT NULL,
  `address` varchar(100) NOT NULL,
  `phoneNumber` varchar(25) NOT NULL,
  `image` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `resident_profile`
--

INSERT INTO `resident_profile` (`uid`, `name`, `address`, `phoneNumber`, `image`) VALUES
('PPCGesdtogNbBCNp3IkTKuIikA63', 'Raphael Dacars', 'Hulo SMB 123', '639424069632', '../e-ligtas-sector/upload/image_1704808147.jpg'),
('uESfipEYxrf3sgppz5LZFoxEtgr2', 'Mian Dela Cruz', 'Hulo SMB', '639931615822', '../e-ligtas-sector/upload/image_1729784813.jpg');

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE `settings` (
  `settings_id` bigint(20) UNSIGNED NOT NULL,
  `settings_name` varchar(255) NOT NULL,
  `settings_description` longtext NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`settings_id`, `settings_name`, `settings_description`, `created_at`, `updated_at`) VALUES
(1, 'About Us', 'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more r, froh the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33', NULL, '2024-01-26 02:26:54'),
(2, 'Legal Policies', 'aContrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from an classicscovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of \"de Finibus Bonorum et Malorum\" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during', NULL, '2024-01-26 02:23:38');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `responder_name` varchar(255) NOT NULL,
  `userfrom` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  `role` varchar(255) NOT NULL DEFAULT 'Sector',
  `email` varchar(255) NOT NULL,
  `verified` enum('pending','active') NOT NULL DEFAULT 'pending',
  `token` varchar(255) DEFAULT NULL,
  `created_by` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `responder_name`, `userfrom`, `username`, `role`, `email`, `verified`, `token`, `created_by`, `password`) VALUES
(2, 'Richard', 'PNP', 'Samson', 'Super Admin', 'macdimatulac234@gmail.com', 'active', ' ', '', '$2y$12$Vs6l5ZGg959nwHNk4q4VZuZ82YyQNRXwKF5PDzpll1mE0zsKvtizS'),
(4, 'Mac Mac', 'MDRRMO', 'miandimatulac23', 'Super Admin', 'miandimatulac23@gmail.com', 'active', ' ', 'richard Tuli', '$2y$12$jnM8t4eT05fXQjibhT8kVu3leCIbEEYnQV4i52LHbUGDTuI3fUQ0S');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `emergency_hotlines`
--
ALTER TABLE `emergency_hotlines`
  ADD PRIMARY KEY (`hotlines_id`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `files`
--
ALTER TABLE `files`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `guidelines`
--
ALTER TABLE `guidelines`
  ADD PRIMARY KEY (`guidelines_id`);

--
-- Indexes for table `guidelines_after`
--
ALTER TABLE `guidelines_after`
  ADD PRIMARY KEY (`id`),
  ADD KEY `guidelines_after_guidelines_id_foreign` (`guidelines_id`);

--
-- Indexes for table `guidelines_before`
--
ALTER TABLE `guidelines_before`
  ADD PRIMARY KEY (`id`),
  ADD KEY `guidelines_before_guidelines_id_foreign` (`guidelines_id`);

--
-- Indexes for table `guidelines_during`
--
ALTER TABLE `guidelines_during`
  ADD PRIMARY KEY (`id`),
  ADD KEY `guidelines_during_guidelines_id_foreign` (`guidelines_id`);

--
-- Indexes for table `login`
--
ALTER TABLE `login`
  ADD PRIMARY KEY (`uid`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`);

--
-- Indexes for table `reports`
--
ALTER TABLE `reports`
  ADD PRIMARY KEY (`report_id`),
  ADD KEY `uid` (`uid`);

--
-- Indexes for table `resident_credentials`
--
ALTER TABLE `resident_credentials`
  ADD PRIMARY KEY (`uid`);

--
-- Indexes for table `resident_profile`
--
ALTER TABLE `resident_profile`
  ADD PRIMARY KEY (`uid`),
  ADD UNIQUE KEY `phone_number` (`phoneNumber`);

--
-- Indexes for table `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`settings_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `files`
--
ALTER TABLE `files`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `guidelines`
--
ALTER TABLE `guidelines`
  MODIFY `guidelines_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `guidelines_after`
--
ALTER TABLE `guidelines_after`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `guidelines_before`
--
ALTER TABLE `guidelines_before`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `guidelines_during`
--
ALTER TABLE `guidelines_during`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reports`
--
ALTER TABLE `reports`
  MODIFY `report_id` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=127;

--
-- AUTO_INCREMENT for table `settings`
--
ALTER TABLE `settings`
  MODIFY `settings_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `guidelines_after`
--
ALTER TABLE `guidelines_after`
  ADD CONSTRAINT `guidelines_after_guidelines_id_foreign` FOREIGN KEY (`guidelines_id`) REFERENCES `guidelines` (`guidelines_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `guidelines_before`
--
ALTER TABLE `guidelines_before`
  ADD CONSTRAINT `guidelines_before_guidelines_id_foreign` FOREIGN KEY (`guidelines_id`) REFERENCES `guidelines` (`guidelines_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `guidelines_during`
--
ALTER TABLE `guidelines_during`
  ADD CONSTRAINT `guidelines_during_guidelines_id_foreign` FOREIGN KEY (`guidelines_id`) REFERENCES `guidelines` (`guidelines_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `resident_profile`
--
ALTER TABLE `resident_profile`
  ADD CONSTRAINT `resident_profile_ibfk_1` FOREIGN KEY (`uid`) REFERENCES `login` (`uid`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
