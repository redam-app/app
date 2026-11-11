<?php

declare(strict_types=1);

namespace App\Models\Process;

use Symfony\Component\Console\Output\OutputInterface;

/**
 * @author      Andreas Knollmann
 * @copyright   2014-2026 Softwareentwicklung Andreas Knollmann
 * @license     http://www.opensource.org/licenses/mit-license.php MIT
 */
class Export extends Base
{
    /**
     * @param array<int, string> $servers
     */
    public function execute(
        OutputInterface $output,
        array $servers,
        string $file,
        string $tempDir,
        bool $onlyColumns,
        bool $onlyRecords,
        bool $removeDatabase
    ): void {
        $databaseServer = sprintf('database:%s', count($servers) > 0 ? implode(',', $servers) : 'all');

        $this->run(
            $output,
            'export.sh',
            ['databaseType', 'databaseVersion'],
            [$databaseServer],
            [
                'file' => $file,
                'tempDir' => $tempDir,
                'onlyColumns' => $onlyColumns,
                'onlyRecords' => $onlyRecords,
                'removeDatabase' => $removeDatabase,
            ],
            [],
            ['file']
        );
    }
}
