-- Drop Tables if they exist
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS shipments CASCADE;
DROP TABLE IF EXISTS return_items CASCADE;
DROP TABLE IF EXISTS sales CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS product_desc CASCADE;

CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_diskann CASCADE;

-- Create Tables
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2),
    inventory NUMERIC(10, 2),
    refurbished BOOLEAN DEFAULT FALSE,
    category VARCHAR(50) DEFAULT 'Eelectronics'
);

CREATE TABLE product_desc (
    vector_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
    embedding vector(1536) NOT NULL,
    product_id INTEGER REFERENCES products(product_id) ON DELETE CASCADE
);

CREATE TABLE customers(
    customer_id SERIAL PRIMARY KEY,
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    sentiment_score NUMERIC(5, 2) DEFAULT 0,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);
CREATE TABLE sales (
    sales_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    quantity NUMERIC(10, 2),
    product_id INTEGER REFERENCES products(product_id),
    sale_date DATE DEFAULT CURRENT_DATE
);
CREATE TABLE return_items (
    return_id SERIAL PRIMARY KEY,
    sales_id INTEGER REFERENCES sales(sales_id),
    return_status VARCHAR(50) NOT NULL,
    reason TEXT,
    status_date DATE DEFAULT CURRENT_DATE
);
CREATE TABLE shipments (
    shipment_id SERIAL PRIMARY KEY,
    sales_id INTEGER REFERENCES sales(sales_id),
    shipment_date DATE DEFAULT CURRENT_DATE,
    shipment_status VARCHAR(50) NOT NULL,
    latest_status_date DATE
);
CREATE TABLE reviews(
    review_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    product_id INTEGER,
    sales_id  INTEGER REFERENCES sales(sales_id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    review_date DATE DEFAULT CURRENT_DATE
);


-- Add Data
INSERT INTO products (name, description, price, inventory, refurbished, category) VALUES
('Macbook Pro M4', 'The MacBook Pro with M4 chip, introduced in 2024, represents a major leap in Apples professional laptop lineup, offering exceptional performance, advanced display technology, and powerful AI capabilities. It comes in 14-inch and 16-inch models, powered by the new M4 Pro and M4 Max chips. The M4 Pro features a 14-core CPU and up to a 20-core GPU, while the M4 Max can be configured with up to a 16-core CPU and a massive 40-core GPU, delivering unprecedented performance for demanding workflows like video editing, 3D rendering, and machine learning tasks. The device features a stunning 14.2-inch Liquid Retina XDR display with a native resolution of 3024x1964, supporting up to 1600 nits of peak brightness for HDR content and ProMotion technology for adaptive refresh rates up to 120Hz. It supports up to four external displays, including one at 8K resolution or 4K at 240Hz via HDMI, and includes Thunderbolt 5 ports for ultra-fast data transfer. Memory options range from 36GB to 128GB depending on the chip configuration, and storage is configurable up to 8TB. The MacBook Pro M4 also introduces Apple Intelligence, a personal AI system that enhances productivity while maintaining strong privacy protections. Battery life is among the best in its class, and the device is available in a sleek Space Black finish 2. With support for ProRes, AV1, Dolby Atmos, and more, the M4 MacBook Pro is designed for professionals who demand top-tier performance and versatility in a portable form factor.', 2085, 50, FALSE, 'Laptops'),
('Macbook Pro M3', 'The MacBook Pro with M3 chip, released in late 2023, is a high-performance laptop tailored for professionals and creatives who need power and portability. It features a 14.2-inch Liquid Retina XDR display with up to 1000 nits of sustained brightness and 1600 nits peak brightness for HDR content, along with ProMotion technology for smooth visuals at up to 120Hz. Powered by the M3 chip, it includes an 8-core CPU and a 10-core GPU, delivering significant improvements in speed and graphics performance. The laptop supports hardware-accelerated encoding and decoding for formats like H.264, HEVC, ProRes, and AV1, making it ideal for media-intensive tasks. It also introduces Apple Intelligence, a personal AI system integrated into macOS Sequoia, enhancing productivity with features like iPhone mirroring, window tiling, and advanced Safari updates. Additional features include a studio-quality three-mic array, a six-speaker sound system with Spatial Audio, and a headphone jack that supports high-impedance headphones. With support for one external display, Thunderbolt ports, HDMI, and an SD card slot, the MacBook Pro M3 offers versatile connectivity. Its long battery life, sustainable design using recycled materials, and accessibility-focused macOS features make it a compelling choice for users seeking a balance of innovation, performance, and eco-conscious design.', 2085, 50, TRUE, 'Laptops'),
('iPhone 14 Pro', 'The iPhone 14 Pro, introduced in September 2022, represents a significant leap in Apples smartphone lineup, blending cutting-edge technology with refined design. It features a 6.1-inch Super Retina XDR OLED display with ProMotion technology, offering adaptive refresh rates up to 120Hz for ultra-smooth visuals. One of its most distinctive innovations is the Dynamic Island, a pill-shaped cutout that replaces the traditional notch and dynamically adapts to show alerts, notifications, and activities in real time. Powered by the A16 Bionic chip, the iPhone 14 Pro delivers exceptional performance and energy efficiency, making it ideal for demanding tasks and gaming. The camera system is a major highlight, boasting a 48MP main sensor—a first for iPhones—alongside 12MP ultra-wide and telephoto lenses. This setup enables advanced computational photography, including ProRAW and ProRes video recording, and significantly enhances low-light performance. Safety features such as Crash Detection and Emergency SOS via satellite add a new layer of security, especially in remote areas. The device is built with a Ceramic Shield front, surgical-grade stainless steel frame, and is rated IP68 for water and dust resistance. It supports 5G connectivity, Face ID, and comes in storage options up to 1TB. With iOS enhancements and a sleek, premium build, the iPhone 14 Pro is designed for users who demand top-tier performance, photography, and innovation in a compact form factor ', 999.99, 20, FALSE, 'Smartphones'),
('iPhone 14 Pro Max', 'The iPhone 14 Pro Max, launched in September 2022, is Apples most advanced iPhone to date, combining top-tier performance, premium design, and cutting-edge features. It boasts a large 6.7-inch Super Retina XDR OLED display with ProMotion technology, offering adaptive refresh rates up to 120Hz for ultra-smooth scrolling and responsiveness. The display also supports up to 2000 nits of peak outdoor brightness, making it exceptionally readable in sunlight. A standout feature is the Dynamic Island, a new interactive area that replaces the notch and fluidly adapts to show alerts, calls, music, and more. Under the hood, the iPhone 14 Pro Max is powered by the A16 Bionic chip, built on a 4nm process, delivering industry-leading speed and efficiency. The camera system is a major leap forward, featuring a 48MP main sensor with second-generation sensor-shift optical image stabilisation, alongside 12MP ultra-wide and telephoto lenses. It supports advanced photography modes like ProRAW, Night mode, and Macro photography, as well as ProRes and Dolby Vision HDR video recording up to 4K at 60 fps. The device also includes Crash Detection and Emergency SOS via satellite, enhancing user safety in emergencies. With a durable Ceramic Shield front, stainless steel frame, and IP68 water resistance, the iPhone 14 Pro Max is built to last. It supports 5G, Face ID, MagSafe accessories, and comes in storage options up to 1TB. Its battery life is among the best in any iPhone, comfortably lasting a full day even with heavy use', 1099.99, 15, TRUE, 'Smartphones'),
('iPhone 13', 'The iPhone 13, released in 2021, is a sleek and powerful smartphone that delivers a balanced mix of performance, battery life, and camera capabilities. It features a 6.1-inch Super Retina XDR OLED display that offers vibrant colours and sharp contrast, making it ideal for media consumption and everyday use. Powered by Apples A15 Bionic chip with a 6-core CPU and 4-core GPU, the iPhone 13 ensures smooth multitasking and efficient performance across apps and games. Its dual-camera system includes a 12MP wide and 12MP ultra-wide lens, enhanced with sensor-shift optical image stabilisation for clearer photos and videos, even in low light. The device supports Cinematic mode for video, allowing users to create depth-of-field effects similar to professional cameras. With up to 19 hours of video playback, 5G connectivity, and MagSafe support for easy attachment of accessories and wireless charging, the iPhone 13 remains a reliable and stylish choice for users who want strong performance without the premium price tag of newer model', 799.99, 30, FALSE, 'Smartphones'),
('iPhone 12', 'The iPhone 12, released in 2020, marked a significant design and performance upgrade in Apples smartphone lineup. It features a 6.1-inch Super Retina XDR OLED display with vibrant colours and sharp contrast, protected by a Ceramic Shield front cover that offers improved durability. Powered by the A14 Bionic chip, the iPhone 12 delivers fast and efficient performance for everyday tasks, gaming, and multitasking. It introduced 5G connectivity for faster wireless speeds and lower latency, enhancing streaming and downloads. The dual-camera system includes a 12MP wide and 12MP ultra-wide lens, enabling high-quality photos and videos, including Night mode and Dolby Vision HDR recording. With a sleek flat-edge design, MagSafe support for easy attachment of accessories and wireless charging, and a lightweight aluminium frame, the iPhone 12 combines style, speed, and functionality in a well-rounded package.', 499.99, 25, TRUE, 'Smartphones'),
('iPhone SE', 'The iPhone SE is Apples compact and budget-friendly smartphone that combines classic design with modern performance. It features a 4.7-inch Retina HD display and retains the familiar Home button with Touch ID for secure authentication. Powered by the A15 Bionic chip—the same processor used in the iPhone 13—it delivers fast and efficient performance for everyday tasks, gaming, and photography. The single 12MP rear camera supports features like Portrait mode, Smart HDR 4, and 4K video recording, offering impressive image quality despite its simplicity. The iPhone SE also supports 5G connectivity, ensuring faster downloads and smoother streaming. With its lightweight design, durable glass and aluminium body, and IP67 water and dust resistance, the iPhone SE is ideal for users who prefer a smaller phone without compromising on speed or essential features.', 399.99, 40, FALSE, 'Smartphones'),
('iPhone 14', 'The iPhone 14 is a refined iteration of its predecessor, offering subtle yet meaningful upgrades that enhance the user experience. It retains the sleek 6.1-inch Super Retina XDR OLED display and is powered by the A15 Bionic chip, now featuring a 5-core GPU for improved graphics performance. The camera system sees notable improvements, with a larger sensor and a faster ƒ/1.5 aperture on the main lens, supported by the new Photonic Engine, which significantly boosts low-light photography. Safety is a standout focus, with the introduction of Crash Detection and Emergency SOS via satellite—features designed to provide peace of mind in critical situations. Battery life is slightly better than the iPhone 13, offering up to 20 hours of video playback. While the design remains largely unchanged, the iPhone 14 delivers a more polished and secure experience, making it a solid choice for users seeking reliability, enhanced photography, and advanced safety features.', 699.99, 5, TRUE, 'Smartphones'),
('iPhone 16 pro', 'The iPhone 16 Pro, unveiled in 2024, is a premium smartphone that blends cutting-edge performance with refined design and intelligent features. It features a 6.3-inch Super Retina XDR OLED display with a resolution of 2622 by 1206 pixels at 460 ppi, offering vibrant colours, deep contrast, and smooth visuals thanks to ProMotion technology with adaptive refresh rates up to 120Hz. The display also supports Always-On functionality, HDR, and True Tone, and is protected by the latest-generation Ceramic Shield front cover. At its core, the iPhone 16 Pro is powered by the A18 Pro chip, which includes a 6-core CPU (2 performance and 4 efficiency cores), a 6-core GPU, and a 16-core Neural Engine. This setup delivers exceptional speed and efficiency, particularly for AI-driven tasks powered by Apple Intelligence, a new personal intelligence system that enhances productivity and privacy. The camera system is a standout feature, boasting a 48MP main sensor with second-generation sensor-shift optical image stabilisation, a 48MP ultra-wide lens, and a 12MP 5x telephoto lens with a tetraprism design for long-range zoom and 3D sensor-shift stabilisation. The iPhone 16 Pro is available in finishes like Black Titanium, White Titanium, Natural Titanium, and Desert Titanium, and offers storage options up to 1TB. It is rated IP68 for water and dust resistance and includes features like Dynamic Island, Haptic Touch, and support for multiple languages and character sets. With its powerful hardware, advanced camera capabilities, and seamless integration of AI, the iPhone 16 Pro is designed for users who demand top-tier performance and innovation in a sleek, durable package.', 2000, 50, FALSE, 'Smartphones'),
('Tablet 0.2', 'Portable tablet with stylus. It is refurbished but in a good condition. Ideal for average daily usage.', 399.99, 10, TRUE, 'Tablets'),
('Tablet 0.2 new', 'Portable tablet with stylus. Brand new. Great option to invest in a durable device.', 650, 40, FALSE, 'Tablets'),
('Jabra Headphone', 'High-quality wireless headphones with noise cancellation.', 199.99, 100, FALSE, 'Headphones'),
('Jabra Headphone Elite', 'The Jabra Elite series of headphones, particularly the Jabra Elite 10, are designed to deliver a premium audio experience for both work and leisure. These true wireless earbuds feature a semi-open design with Jabras unique ComfortFit technology, developed from over 62,000 ear scans to ensure a secure, pressure-free fit for all-day wear. The Elite 10 is equipped with 10mm speakers that produce rich, immersive sound, enhanced by Spatial Sound with Dolby Head Tracking for a cinematic audio experience. One of the standout features is the Jabra Advanced Active Noise Cancellation (ANC), which automatically adapts to your environment and is twice as effective as their standard ANC. This makes them ideal for noisy settings like commutes or open offices. For calls, the Elite 10 uses a 6-microphone array with intelligent noise-reduction algorithms that isolate your voice from background chatter, ensuring crystal-clear communication. Battery life is also impressive, offering 6 hours of continuous playback (4 hours with Dolby Head Tracking enabled) and up to 27 hours with the wireless charging case. The earbuds support multi-device connectivity, allowing seamless switching between devices like your phone and laptop. With support for voice assistants like Siri, Google Assistant, and Alexa, and a durable build designed for everyday use, the Jabra Elite headphones are a versatile and high-performance choice for users who value comfort, clarity, and convenience.', 249.99, 50, FALSE, 'Headphones'),
('Jabra Headphone Sport', 'The **Jabra Sport** headphones are designed specifically for active users who demand durability, comfort, and high-performance audio during workouts and outdoor activities. These wireless headphones are built to withstand intense physical activity and harsh conditions, featuring high **IP ratings** for water and dust resistance—such as **IP67** for the Jabra Elite Sport and **IP56** for the Elite Active 65t—ensuring protection against sweat, rain, and dust. Their secure fit and lightweight design make them ideal for running, gym sessions, and other vigorous exercises. Jabra Sport models offer more than just music playback. They include advanced fitness features like **heart rate monitoring**, **automatic rep counting**, **VO2 Max tracking**, and **in-ear coaching**, all accessible through the **Jabra Sport Life app**. This app allows users to plan workouts, track routes, and receive real-time feedback, making the headphones a comprehensive fitness companion. The sound quality is tuned for both music and calls, with noise-isolating designs and multiple microphones for clear voice communication. Battery life is another strong point, with models like the Elite Sport offering up to **13.5 hours** of use with the charging case. Whether you are training for a competition or simply staying fit, Jabra Sport headphones provide the resilience, smart features, and audio performance needed to stay motivated and on track.', 149.99, 75, FALSE, 'Headphones'),
('Jabra Headphone Studio', 'The **Jabra Studio** headphones are designed for professional use, offering a wired, on-ear configuration that prioritises audio fidelity and reliability—ideal for studio environments, conference calls, and content creation. These headphones feature a **dynamic driver system** with a **40mm diaphragm**, delivering stereo sound with a frequency response range of **20Hz to 20,000Hz**, which ensures clear highs, rich mids, and deep bass. The **200 Ohm impedance** supports high-quality audio output, especially when paired with professional-grade equipment. Built with materials like polyurethane, PVC, polycarbonate, and ABS plastic, the Jabra Studio headphones are both durable and lightweight, weighing approximately **324 grams**. Their **foldable design** enhances portability, making them easy to store and transport. While they are primarily wired for consistent audio transmission and zero latency—crucial in studio settings—they also support **Bluetooth connectivity** for flexible use in less critical scenarios. Additionally, they include **active noise cancellation**, helping to minimise ambient distractions and maintain focus during recording or calls. These headphones are tailored for users who value precision, comfort, and professional-grade performance, making them a solid choice for audio engineers, broadcasters, and remote professionals alike.', 179.99, 60, FALSE, 'Headphones'),
('Jabra Headphone Pro', 'The **Jabra Pro** series, particularly the **Jabra Pro 900 Series**, is a line of professional wireless headsets designed for office environments, contact centres, and customer service teams. These headsets offer both **DECT and Bluetooth®** connectivity options, allowing users to connect seamlessly to desk phones, softphones, tablets, and smartphones depending on the model. Known for their **ease of use**, the Pro series features an intuitive design that supports fast user adoption, with models available in **mono and duo** versions to suit different preferences. The headsets deliver **clear, lifelike audio quality** and incorporate **Jabra SafeTone™** technology, which protects users hearing by limiting average volume exposure throughout the day. With a **wireless range of up to 120 metres (395 feet)** and **talk time of up to 12 hours**, the Jabra Pro headsets support mobility and productivity across the office. They also include **noise-cancelling microphones**, adjustable headbands, and leatherette ear cushions for comfort during extended use. The Pro 900 Series is compatible with **Jabra Direct** and **Jabra Xpress**, enabling centralised device management and software updates to keep the headset fleet current and secure. With fast charging capabilities—50% charge in 50 minutes and full charge in under 3 hours—these headsets are built for efficiency. Whether for single-device use or multi-device flexibility, the Jabra Pro series offers a reliable, high-quality solution for professional communication needs.', 299.99, 30, FALSE, 'Headphones'),
('Sony TV 55 inch', 'The Sony BRAVIA 5 55” Class Mini LED 4K HDR Google TV (2025) is a premium television designed to deliver an immersive and intelligent viewing experience. It features a Mini LED panel powered by Sonys XR Backlight Master Drive™, which precisely controls thousands of LEDs to produce exceptional brightness and deep contrast. The display supports 4K HDR and is enhanced by the XR Triluminos Pro™ technology, allowing it to render billions of real-world colours with remarkable accuracy. At the heart of the TV is the XR Processor™ with AI, which intelligently analyses and optimises every scene in real time, boosting colour, clarity, and contrast for lifelike visuals. This 55-inch model also integrates Google TV, offering seamless access to streaming apps, voice control via Google Assistant, and personalised content recommendations. It supports HDMI 2.1, making it ideal for gamers who want to take advantage of features like 4K at 120Hz, Variable Refresh Rate (VRR), and Auto Low Latency Mode (ALLM). The TV design is sleek and modern, with minimal bezels that maximise screen space and blend elegantly into any living room setup. Whether you are watching movies, gaming, or streaming your favourite shows, the Sony BRAVIA 5 delivers a vibrant, responsive, and cinematic experience.', 799.99, 20, FALSE, 'TVs'),
('Sony TV 65 inch', 'The **Sony BRAVIA XR 65” X90CL** is a high-performance 4K HDR smart TV designed to deliver a cinematic viewing experience with intelligent picture and sound enhancements. It features a **Full Array LED panel** powered by the **Cognitive Processor XR™**, which mimics the way the human brain processes visuals to produce natural colours, deep blacks, and high peak brightness. The **XR Triluminos Pro™** technology enhances colour accuracy, rendering billions of shades with lifelike precision, while the advanced local dimming structure ensures excellent contrast and depth across scenes. This 65-inch model runs on **Google TV**, giving users seamless access to a wide range of streaming apps and services, all in one place. It supports **voice control** via Google Assistant and is compatible with **Apple AirPlay**, allowing easy integration with Apple devices. The TV also includes features like **XR Motion Clarity** for smooth, blur-free action scenes, and **Acoustic Multi-Audio™**, which aligns sound with the picture for a more immersive experience. With its sleek design, intuitive interface, and powerful processing, the Sony BRAVIA XR 65” X90CL is ideal for users who want premium picture quality, smart features, and a refined home entertainment setup.', 999.99, 5, TRUE, 'TVs'),
('SAMSUNG 75-Inch Crystal UHD DU7100 Series ', 'The **Samsung 75-Inch Crystal UHD DU7100 Series** is a feature-rich 4K smart TV designed to deliver vibrant visuals, smart connectivity, and a seamless entertainment experience. Powered by the **Crystal Processor 4K**, it enhances picture clarity and upscales lower-resolution content to near-4K quality, ensuring sharp detail and vivid colours. The display supports **PurColor** and **Contrast Enhancer** technologies, which work together to produce lifelike images with rich depth and dynamic contrast. Its **near bezel-less design** maximises screen space, offering an immersive viewing experience ideal for movies, sports, and gaming. Running on **Samsungs Tizen OS**, the DU7100 provides access to a wide range of streaming apps and services, along with a **Gaming Hub** that consolidates cloud gaming platforms and console access in one place—no console required. It also includes **Samsung TV Plus**, offering over 800 free channels across news, sports, entertainment, and more. For security, the TV is equipped with **Samsung Knox**, which protects user data and connected devices with multiple layers of hardware and software security. Additional features include **4K upscaling**, **HDR support**, and **Q-Symphony** compatibility for synchronised audio when paired with compatible Samsung soundbars. With its sleek design, smart features, and robust performance, the Samsung DU7100 75-inch TV is a compelling choice for users seeking a large-screen, all-in-one entertainment solution.', 1599.99, 10, FALSE, 'TVs'),
('Sony TV OLED', 'The **Sony OLED TV** range, including models like the BRAVIA XR series, delivers a premium viewing experience by combining cutting-edge display technology with immersive sound and intelligent processing. At the heart of these TVs is the **XR Processor™**, which enhances picture and sound by mimicking the way humans perceive visuals and audio. This processor powers features like **XR Triluminos Pro™**, which brings over a billion colours to life with exceptional accuracy, analysing saturation, hue, and brightness to produce natural, vivid images. Sony OLED TVs use **millions of self-illuminating pixels**, allowing for perfect blacks, dazzling highlights, and an incredibly wide colour spectrum. This results in stunning contrast and detail, especially in dark scenes. The **QD-OLED** panels further enhance colour vibrancy and clarity, making them ideal for both cinematic content and gaming. Sound is equally impressive thanks to **Acoustic Surface Audio+™** technology, which turns the screen itself into a speaker. This ensures that audio comes directly from where the action is happening on screen, creating a more immersive and synchronised experience. These TVs also support **4K HDR**, **Dolby Vision**, and **IMAX Enhanced**, and run on **Google TV**, offering access to a wide range of streaming services, voice control, and smart home integration. With sleek, minimalist designs and advanced features tailored for both entertainment and productivity, Sony OLED TVs are a top-tier choice for users seeking exceptional picture quality, immersive sound, and smart functionality in a stylish package.', 1999.99, 20, FALSE, 'TVs'),
('SAMSUNG TV OLED', 'The **Samsung S95C OLED TV** is a flagship model in Samsung 4K OLED lineup, designed to deliver a premium home entertainment experience with cutting-edge display technology and smart features. Available in sizes including 65 inches, the S95C features a **Quantum Dot OLED panel**, which combines the deep blacks and infinite contrast of OLED with the vibrant colour volume of Quantum Dot technology. This results in stunning picture quality with exceptional brightness, rich colours, and precise detail, even in challenging lighting conditions. The TV is powered by Samsung **Neural Quantum Processor 4K**, which uses AI-based upscaling to enhance lower-resolution content and optimise visuals in real time. It supports **HDR10+**, **HLG**, and **Dolby Atmos**, ensuring a cinematic experience with both visuals and sound. The S95C also includes **Object Tracking Sound+**, which creates a more immersive audio environment by matching sound movement with on-screen action. With its ultra-slim design and **One Connect Box**, the S95C offers a clean, minimalist aesthetic that fits seamlessly into modern living spaces. It runs on **Tizen OS**, providing access to a wide range of streaming apps, voice assistants, and Samsung Gaming Hub, which supports features like **4K at 144Hz**, **VRR**, and **ALLM** for next-gen gaming. The Samsung S95C OLED is ideal for users who want top-tier picture quality, immersive sound, and a sleek, future-ready smart TV platform.', 1300.99, 2, TRUE, 'TVs')
;

INSERT INTO customers (city, state, country, sentiment_score, name, email) VALUES
('New York', 'NY', 'USA', 4.5, 'John Doe', 'jd@jd.ca'),
('Los Angeles', 'CA', 'USA', 3, 'Jane Smith', 'js@gmail.com'),
('Chicago', 'IL', 'USA', 3.5, 'Alice Johnson', 'aj@yahoo.com'),
('Houston', 'TX', 'USA', 4, 'Bob Brown', 'bb@dl.com'),
('Phoenix', 'AZ', 'USA', 1, 'Charlie White', 'charlie@yahoo.ca'),
('San Francisco', 'CA', 'USA', 0, 'David Green', 'davidg@g.com'),
('Seattle', 'WA', 'USA', 0, 'Eve Black', 'eve@example.ca'),
('New york', 'NY', 'USA', 0, 'Frank Blue', 'fb#test.com'),
('Seattle', 'WA', 'USA', 0,  'Grace Yellow', 'grace@yellow.co'),
('Miami', 'FL', 'USA', 0, 'Hank Purple', 'hp@test.com'),
('Los Angeles', 'CA', 'USA', 0, 'Zara Orange', 'zara@orange.com')
;

INSERT INTO sales (customer_id, quantity, product_id) VALUES
(1, 1, 1),
(2, 2, 2),
(2, 1, 3),
(3, 3, 1),
(5, 2, 2),
(4, 1, 4),
(1, 1, 5),
(2, 1, 6),
(3, 2, 7),
(4, 1, 8),
(5, 1, 9),
(6, 2, 10),
(7, 1, 11),
(8, 3, 12),
(9, 2, 13),
(10, 1, 14),
(1, 2, 15),
(2, 1, 16),
(3, 3, 17),
(4, 2, 18)
;

INSERT INTO return_items (sales_id, return_status, reason, status_date) VALUES
(3, 'Pending', 'Wrong item sent', '2023-10-03'),
(4, 'Completed', 'Item not as described', '2023-10-04'),
(5, 'Pending', 'Item arrived damaged', '2023-10-05'),
(10, 'Completed', 'Changed my mind', '2023-10-06')
;

INSERT INTO reviews (customer_id, product_id, sales_id, rating, review_text) VALUES
(1, 1, 1, 5, 'Excellent laptop!'),
(2, 2, 2, 4, 'Great smartphone but a bit pricey.'),
(2, 1, 3, 2, 'I was sent the wrong item.'),
(3, 1, 4, 2, 'wrong colour!! return was easy'),
(5, 2, 5, 1, 'received a damaged item, disappointed!!!'),
(4, 4, 6, 5, 'Love this phone!'),
(1, 5, 7, 4, 'Great performance and battery life.'),
(2, 6, 8, 3, 'Decent phone but not the best.'),
(3, 7, 9, 5, 'Perfect for my needs!'),
(4, 8, 10, 3, 'Good quality but a bit expensive.')
;

INSERT INTO shipments (sales_id, shipment_date, shipment_status, latest_status_date) VALUES
(1, '2023-10-01', 'Delivered', '2023-10-01'),
(2, '2023-10-02', 'Delivered', '2023-10-02'),
(3, '2023-10-03', 'Delivered', '2023-10-03'),
(4, '2023-10-04', 'Delivered', '2023-10-04'),
(5, '2023-10-05', 'Delivered', '2023-10-05'),
(6, '2023-10-06', 'Delivered', '2023-10-06'),
(7, '2023-10-07', 'Delivered', '2023-10-07'),
(8, '2023-10-08', 'Delivered', '2023-10-08'),
(9, '2023-10-09', 'Delivered', '2023-10-09'),
(10, '2023-10-10', 'Delivered', '2023-10-10'),
(11, '2023-10-11', 'In Transit', '2023-10-11'),
(12, '2023-10-12', 'In Transit', '2023-10-12'),
(13, '2023-10-13', 'In Transit', '2023-10-13'),
(14, '2023-10-14', 'In Transit', '2023-10-14'),
(15, '2023-10-15', 'In Transit', '2023-10-15'),
(16, '2023-10-16', 'In Transit', '2023-10-16'),
(17, '2023-10-17', 'Preparing', '2023-10-17'),
(18, '2023-10-18', 'Preparing', '2023-10-18'),
(19, '2023-10-19', 'Preparing', '2023-10-19'),
(20, '2023-10-20', 'Not Started', '2023-10-20')
;
