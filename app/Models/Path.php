<?php

declare(strict_types=1);

namespace App\Models;

use FeWeDev\Base\Files;

/**
 * @author      Andreas Knollmann
 * @copyright   2014-2026 Softwareentwicklung Andreas Knollmann
 * @license     http://www.opensource.org/licenses/mit-license.php MIT
 */
class Path
{
    public function __construct(protected Files $files) {}

    public function getBasePath(): string
    {
        $basePath = base_path();

        if (str_contains($basePath, 'phar://')) {
            $phar = new \Phar($basePath);

            $basePath = sprintf('/tmp/redam/%s', app()->version());

            if (!file_exists($basePath)) {
                $this->files->createDirectory($basePath, 0755);

                $phar->extractTo($basePath);

                $files = scandir($basePath);

                foreach ($files as $file) {
                    $filePath = sprintf('%s%s%s', $basePath, DIRECTORY_SEPARATOR, $file);

                    if (is_file($filePath)) {
                        unlink($filePath);
                    } else if (is_dir($filePath) && $file !== '.' && $file !== '..' && $file !== 'scripts') {
                        $this->files->removeDirectory($filePath);
                    }
                }

                $scriptsPath = sprintf('%s%s%s', $basePath, DIRECTORY_SEPARATOR, 'scripts');
                $directory = new \RecursiveDirectoryIterator($scriptsPath);
                $iterator = new \RecursiveIteratorIterator($directory);
                $regex = new \RegexIterator($iterator, '/^.+\.sh$/i', \RegexIterator::GET_MATCH);

                foreach ($regex as $file) {
                    $file = reset($file);
                    chmod($file, 0755);
                }
            }
        }

        return $basePath;
    }
}
